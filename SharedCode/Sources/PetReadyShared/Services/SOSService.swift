import Foundation

public enum SOSServiceError: LocalizedError {
    case caseNotFound
    case caseClosed

    public var errorDescription: String? {
        switch self {
        case .caseNotFound:
            return "The SOS case could not be found."
        case .caseClosed:
            return "The SOS case is already closed."
        }
    }
}

public protocol SOSServiceProtocol: AnyObject, Sendable {
    func createCase(_ request: SOSRequest) async throws -> SOSCase
    func fetchCases() async -> [SOSCase]
    func observeCases(update: @escaping ([SOSCase]) -> Void)
    func cancelCase(id: UUID, reason: String?) async throws -> SOSCase
    func acceptCase(id: UUID, riderId: UUID) async throws -> SOSCase
    func declineCase(id: UUID, riderId: UUID) async
    func markEnRoute(id: UUID, riderId: UUID, etaMinutes: Int?, distanceKm: Double?) async throws -> SOSCase
    func completeCase(id: UUID) async throws -> SOSCase
    func recordBeacon(id: UUID, coordinate: Coordinate, note: String?) async
}

public final class SOSService: SOSServiceProtocol, @unchecked Sendable {
    public static let shared = SOSService()
    private let queue = DispatchQueue(label: "com.petready.sos.service", qos: .userInitiated, attributes: .concurrent)
    private var cases: [UUID: SOSCase] = [:]
    private var observers: [UUID: ([SOSCase]) -> Void] = [:]

    public init() {}

    public func createCase(_ request: SOSRequest) async throws -> SOSCase {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                let attachments = request.attachmentURLs.map { SOSAttachment(url: $0) }
                let created = self.makeCase(from: request, attachments: attachments)
                self.cases[created.id] = created
                self.dispatchSnapshot()
                continuation.resume(returning: created)
            }
        }
    }

    public func fetchCases() async -> [SOSCase] {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: self.sortedCases())
            }
        }
    }

    public func observeCases(update: @escaping ([SOSCase]) -> Void) {
        let token = UUID()
        queue.async(flags: .barrier) {
            self.observers[token] = update
            let snapshot = self.sortedCases()
            self.send(snapshot, to: [token: update])
        }
    }

    public func cancelCase(id: UUID, reason: String?) async throws -> SOSCase {
        try await mutateCase(id: id, allowClosed: false) { [self] item in
            item.status = .cancelled
            let message: String
            if let reason, !reason.isEmpty {
                message = "SOS cancelled: \(reason)"
            } else {
                message = "SOS cancelled"
            }
            self.appendEvent(message, actor: "owner", into: &item)
        }
    }

    public func acceptCase(id: UUID, riderId: UUID) async throws -> SOSCase {
        try await mutateCase(id: id, allowClosed: false) { [self] item in
            item.riderId = riderId
            item.status = .assigned
            self.appendEvent("Assigned to rider \(riderId.uuidString.prefix(6))", actor: "rider", into: &item)
        }
    }

    public func declineCase(id: UUID, riderId: UUID) async {
        _ = try? await mutateCase(id: id, allowClosed: true) { [self] item in
            if item.riderId == riderId {
                item.riderId = nil
                item.status = .pending
            }
            self.appendEvent("Declined by rider \(riderId.uuidString.prefix(6))", actor: "rider", into: &item)
        }
    }

    public func markEnRoute(id: UUID, riderId: UUID, etaMinutes: Int?, distanceKm: Double?) async throws -> SOSCase {
        try await mutateCase(id: id, allowClosed: false) { [self] item in
            item.riderId = riderId
            item.status = .enRoute
            item.etaMinutes = etaMinutes
            item.distanceKm = distanceKm
            self.appendEvent("Rider en route (ETA \(etaMinutes.map { "\($0)m" } ?? "—"))", actor: "rider", into: &item)
        }
    }

    public func completeCase(id: UUID) async throws -> SOSCase {
        try await mutateCase(id: id, allowClosed: false) { [self] item in
            item.status = .completed
            self.appendEvent("Marked as completed", actor: "admin", into: &item)
        }
    }

    public func recordBeacon(id: UUID, coordinate: Coordinate, note: String?) async {
        _ = try? await mutateCase(id: id, allowClosed: true) { [self] item in
            item.lastKnownLocation = coordinate
            self.appendEvent("Beacon \(coordinate.latitude),\(coordinate.longitude)\(note.map { " – \($0)" } ?? "")", actor: "rider", into: &item)
        }
    }

    // MARK: - Helpers

    private func makeCase(from request: SOSRequest, attachments: [SOSAttachment]) -> SOSCase {
        SOSCase(
            requesterId: request.requesterId,
            riderId: nil,
            petId: request.petId,
            incidentType: request.incidentType,
            priority: request.priority,
            pickup: request.pickup,
            destination: request.destination,
            contactNumber: request.contactNumber,
            status: .pending,
            notes: request.notes,
            attachments: attachments,
            etaMinutes: nil,
            distanceKm: nil,
            lastKnownLocation: nil,
            events: [SOSEvent(message: "SOS created", actor: "owner")]
        )
    }

    private func mutateCase(id: UUID, allowClosed: Bool, mutation: @escaping (inout SOSCase) -> Void) async throws -> SOSCase {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                guard var item = self.cases[id] else {
                    continuation.resume(throwing: SOSServiceError.caseNotFound)
                    return
                }
                if !allowClosed, item.status == .completed || item.status == .cancelled {
                    continuation.resume(throwing: SOSServiceError.caseClosed)
                    return
                }
                mutation(&item)
                item.updatedAt = Date()
                self.cases[id] = item
                self.dispatchSnapshot()
                continuation.resume(returning: item)
            }
        }
    }

    private func appendEvent(_ message: String, actor: String, into item: inout SOSCase) {
        item.events.append(SOSEvent(message: message, actor: actor))
    }

    private func sortedCases() -> [SOSCase] {
        cases.values.sorted { $0.createdAt > $1.createdAt }
    }

    private func dispatchSnapshot() {
        let snapshot = sortedCases()
        send(snapshot, to: observers)
    }

    private func send(_ snapshot: [SOSCase], to observers: [UUID: ([SOSCase]) -> Void]) {
        observers.values.forEach { observer in
            DispatchQueue.main.async {
                observer(snapshot)
            }
        }
    }
}
