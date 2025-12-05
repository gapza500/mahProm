import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

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

#if canImport(FirebaseFirestore)
public final class FirestoreSOSService: SOSServiceProtocol, @unchecked Sendable {
    private let collection = Firestore.firestore().collection("sosCases")
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    public init() {}

    public func createCase(_ request: SOSRequest) async throws -> SOSCase {
        let id = UUID()
        let now = Date()
        let attachments = request.attachmentURLs.map { SOSAttachment(url: $0) }
        var caseItem = SOSCase(
            id: id,
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
            events: [SOSEvent(message: "SOS created", actor: "owner", timestamp: now)],
            createdAt: now,
            updatedAt: now,
            syncedAt: now,
            isDirty: false
        )

        try await collection.document(id.uuidString).setData(encode(caseItem))
        return caseItem
    }

    public func fetchCases() async -> [SOSCase] {
        do {
            let snapshot = try await collection.order(by: "createdAt", descending: true).getDocuments()
            return snapshot.documents.compactMap { decode(document: $0) }
        } catch {
            return []
        }
    }

    public func observeCases(update: @escaping ([SOSCase]) -> Void) {
        listener?.remove()
        listener = collection.order(by: "createdAt", descending: true).addSnapshotListener { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else { return }
            let cases = docs.compactMap { self.decode(document: $0) }
            DispatchQueue.main.async {
                update(cases)
            }
        }
    }

    public func cancelCase(id: UUID, reason: String?) async throws -> SOSCase {
        try await updateCase(id: id) { item in
            item.status = .cancelled
            let message = (reason?.isEmpty == false) ? "SOS cancelled: \(reason!)" : "SOS cancelled"
            item.events.append(SOSEvent(message: message, actor: "owner"))
        }
    }

    public func acceptCase(id: UUID, riderId: UUID) async throws -> SOSCase {
        try await updateCase(id: id) { item in
            item.riderId = riderId
            item.status = .assigned
            item.events.append(SOSEvent(message: "Assigned to rider \(riderId.uuidString.prefix(6))", actor: "rider"))
        }
    }

    public func declineCase(id: UUID, riderId: UUID) async {
        _ = try? await updateCase(id: id, allowClosed: true) { item in
            if item.riderId == riderId { item.riderId = nil; item.status = .pending }
            item.events.append(SOSEvent(message: "Declined by rider \(riderId.uuidString.prefix(6))", actor: "rider"))
        }
    }

    public func markEnRoute(id: UUID, riderId: UUID, etaMinutes: Int?, distanceKm: Double?) async throws -> SOSCase {
        try await updateCase(id: id) { item in
            item.riderId = riderId
            item.status = .enRoute
            item.etaMinutes = etaMinutes
            item.distanceKm = distanceKm
            item.events.append(SOSEvent(message: "Rider en route (ETA \(etaMinutes.map { "\($0)m" } ?? "—"))", actor: "rider"))
        }
    }

    public func completeCase(id: UUID) async throws -> SOSCase {
        try await updateCase(id: id) { item in
            item.status = .completed
            item.events.append(SOSEvent(message: "Marked as completed", actor: "admin"))
        }
    }

    public func recordBeacon(id: UUID, coordinate: Coordinate, note: String?) async {
        _ = try? await updateCase(id: id, allowClosed: true) { item in
            item.lastKnownLocation = coordinate
            item.events.append(SOSEvent(message: "Beacon \(coordinate.latitude),\(coordinate.longitude)\(note.map { " – \($0)" } ?? "")", actor: "rider"))
        }
    }

    // MARK: - Helpers

    private func updateCase(id: UUID, allowClosed: Bool = false, mutation: @escaping (inout SOSCase) -> Void) async throws -> SOSCase {
        let docRef = collection.document(id.uuidString)
        let snapshot = try await docRef.getDocument()
        guard var item = decode(document: snapshot) else {
            throw SOSServiceError.caseNotFound
        }
        if !allowClosed, item.status == .completed || item.status == .cancelled {
            throw SOSServiceError.caseClosed
        }
        mutation(&item)
        item.updatedAt = Date()
        item.syncedAt = Date()
        try await docRef.setData(encode(item), merge: true)
        return item
    }

    private func encode(_ item: SOSCase) -> [String: Any] {
        return [
            "id": item.id.uuidString,
            "requesterId": item.requesterId.uuidString,
            "riderId": item.riderId?.uuidString as Any,
            "petId": item.petId?.uuidString as Any,
            "incidentType": item.incidentType.rawValue,
            "priority": item.priority.rawValue,
            "pickup": ["latitude": item.pickup.latitude, "longitude": item.pickup.longitude],
            "destination": item.destination.map { ["latitude": $0.latitude, "longitude": $0.longitude] } as Any,
            "contactNumber": item.contactNumber as Any,
            "status": item.status.rawValue,
            "notes": item.notes as Any,
            "attachments": item.attachments.map { ["id": $0.id.uuidString, "url": $0.url.absoluteString, "kind": $0.kind.rawValue] },
            "etaMinutes": item.etaMinutes as Any,
            "distanceKm": item.distanceKm as Any,
            "lastKnownLocation": item.lastKnownLocation.map { ["latitude": $0.latitude, "longitude": $0.longitude] } as Any,
            "events": item.events.map { ["id": $0.id.uuidString, "message": $0.message, "actor": $0.actor, "timestamp": $0.timestamp] },
            "createdAt": item.createdAt,
            "updatedAt": item.updatedAt,
            "syncedAt": item.syncedAt as Any,
            "isDirty": item.isDirty
        ]
    }

    private func decode(document: DocumentSnapshot) -> SOSCase? {
        guard let data = document.data() else { return nil }
        guard
            let requesterIdString = data["requesterId"] as? String,
            let requesterId = UUID(uuidString: requesterIdString),
            let incidentRaw = data["incidentType"] as? String,
            let incidentType = SOSIncidentType(rawValue: incidentRaw),
            let priorityRaw = data["priority"] as? String,
            let priority = SOSPriority(rawValue: priorityRaw),
            let statusRaw = data["status"] as? String,
            let status = SOSStatus(rawValue: statusRaw),
            let pickupDict = data["pickup"] as? [String: Any],
            let pickupLat = pickupDict["latitude"] as? Double,
            let pickupLng = pickupDict["longitude"] as? Double,
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? data["createdAt"] as? Date,
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? data["updatedAt"] as? Date
        else {
            return nil
        }

        let id = UUID(uuidString: data["id"] as? String ?? document.documentID) ?? UUID()
        let petId = (data["petId"] as? String).flatMap(UUID.init(uuidString:))
        let riderId = (data["riderId"] as? String).flatMap(UUID.init(uuidString:))
        let destination: Coordinate?
        if let destDict = data["destination"] as? [String: Any],
           let dLat = destDict["latitude"] as? Double,
           let dLng = destDict["longitude"] as? Double {
            destination = Coordinate(latitude: dLat, longitude: dLng)
        } else {
            destination = nil
        }
        let attachments: [SOSAttachment]
        if let rawAttachments = data["attachments"] as? [[String: Any]] {
            attachments = rawAttachments.compactMap { dict in
                guard let urlString = dict["url"] as? String, let url = URL(string: urlString) else { return nil }
                let kind = SOSAttachment.Kind(rawValue: dict["kind"] as? String ?? "photo") ?? .photo
                let id = UUID(uuidString: dict["id"] as? String ?? "") ?? UUID()
                return SOSAttachment(id: id, url: url, kind: kind)
            }
        } else {
            attachments = []
        }
        let events: [SOSEvent]
        if let rawEvents = data["events"] as? [[String: Any]] {
            events = rawEvents.compactMap { dict in
                guard let message = dict["message"] as? String, let actor = dict["actor"] as? String else { return nil }
                let timestamp: Date
                if let ts = dict["timestamp"] as? Timestamp {
                    timestamp = ts.dateValue()
                } else if let date = dict["timestamp"] as? Date {
                    timestamp = date
                } else {
                    timestamp = Date()
                }
                let id = UUID(uuidString: dict["id"] as? String ?? "") ?? UUID()
                return SOSEvent(id: id, message: message, actor: actor, timestamp: timestamp)
            }
        } else {
            events = []
        }

        let etaMinutes = data["etaMinutes"] as? Int
        let distanceKm = data["distanceKm"] as? Double
        let contactNumber = data["contactNumber"] as? String
        let lastKnownLocation: Coordinate?
        if let locDict = data["lastKnownLocation"] as? [String: Any],
           let lLat = locDict["latitude"] as? Double,
           let lLng = locDict["longitude"] as? Double {
            lastKnownLocation = Coordinate(latitude: lLat, longitude: lLng)
        } else {
            lastKnownLocation = nil
        }

        let notes = data["notes"] as? String
        let syncedAt = (data["syncedAt"] as? Timestamp)?.dateValue() ?? data["syncedAt"] as? Date
        let isDirty = data["isDirty"] as? Bool ?? false

        return SOSCase(
            id: id,
            requesterId: requesterId,
            riderId: riderId,
            petId: petId,
            incidentType: incidentType,
            priority: priority,
            pickup: Coordinate(latitude: pickupLat, longitude: pickupLng),
            destination: destination,
            contactNumber: contactNumber,
            status: status,
            notes: notes,
            attachments: attachments,
            etaMinutes: etaMinutes,
            distanceKm: distanceKm,
            lastKnownLocation: lastKnownLocation,
            events: events,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncedAt: syncedAt,
            isDirty: isDirty
        )
    }
}
#endif

public enum SOSServiceFactory {
    public static func make() -> SOSServiceProtocol {
#if canImport(FirebaseFirestore)
        if NSClassFromString("FIRFirestore") != nil {
            return FirestoreSOSService()
        }
#endif
        return SOSService.shared
    }
}
