import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

#if canImport(FirebaseFirestore)
public typealias ConsultationListenerToken = ListenerRegistration
#else
public typealias ConsultationListenerToken = AnyObject
#endif

public enum ConsultationServiceError: LocalizedError {
    case unavailable
    case ownerUnavailable

    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Consultation service is not available on this build."
        case .ownerUnavailable:
            return "We could not determine your profile to start the consult."
        }
    }
}

@MainActor
public final class VetConsultationService {
    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    private var sessionsCollection: CollectionReference { db.collection("consultations") }
    private var usersCollection: CollectionReference { db.collection("users") }
    #endif

    public init() {}

    public func fetchAvailableVets(limit: Int = 12) async throws -> [VetAvailability] {
        #if canImport(FirebaseFirestore)
        let snapshot = try await usersCollection
            .whereField("role", isEqualTo: UserType.vet.rawValue)
            .whereField("status", isEqualTo: UserApprovalStatus.approved.rawValue)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { Self.decodeVet(document: $0) }
        #else
        return Self.sampleVets
        #endif
    }

    @discardableResult
    public func observeOwnerSessions(ownerId: String, handler: @escaping ([ConsultationSession]) -> Void) -> ConsultationListenerToken? {
        #if canImport(FirebaseFirestore)
        return sessionsCollection
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard error == nil, let documents = snapshot?.documents else { return }
                let sessions = documents.compactMap { Self.decodeSession(id: $0.documentID, data: $0.data()) }
                Task { @MainActor in handler(sessions) }
            }
        #else
        handler(Self.sampleSessions)
        return nil
        #endif
    }

    nonisolated public func stopListening(_ token: ConsultationListenerToken?) {
        #if canImport(FirebaseFirestore)
        token?.remove()
        #endif
    }

    public func requestConsultation(owner: UserProfile, preferredVet: VetAvailability?) async throws -> ConsultationSession {
        #if canImport(FirebaseFirestore)
        let document = sessionsCollection.document()
        let now = Date()
        var payload: [String: Any] = [
            "ownerId": owner.id,
            "ownerName": owner.displayName,
            "status": ConsultationStatus.waiting.rawValue,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let vet = preferredVet {
            payload["preferredVetId"] = vet.id
            payload["preferredVetName"] = vet.displayName
        }
        payload["ownerEmail"] = owner.email
        try await document.setData(payload, merge: true)
        return ConsultationSession(
            id: document.documentID,
            ownerId: owner.id,
            ownerName: owner.displayName,
            vetId: preferredVet?.id,
            vetName: preferredVet?.displayName,
            status: .waiting,
            createdAt: now,
            updatedAt: now
        )
        #else
        throw ConsultationServiceError.unavailable
        #endif
    }

    @discardableResult
    public func observeWaitingQueue(handler: @escaping ([ConsultationSession]) -> Void) -> ConsultationListenerToken? {
        #if canImport(FirebaseFirestore)
        return sessionsCollection
            .whereField("status", in: [
                ConsultationStatus.waiting.rawValue,
                ConsultationStatus.queued.rawValue
            ])
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                guard error == nil, let docs = snapshot?.documents else { return }
                let sessions = docs.compactMap { Self.decodeSession(id: $0.documentID, data: $0.data()) }
                Task { @MainActor in handler(sessions) }
            }
        #else
        handler(Self.sampleSessions)
        return nil
        #endif
    }

    @discardableResult
    public func observeActiveSessions(forVetId vetId: String, handler: @escaping ([ConsultationSession]) -> Void) -> ConsultationListenerToken? {
        #if canImport(FirebaseFirestore)
        return sessionsCollection
            .whereField("vetId", isEqualTo: vetId)
            .whereField("status", in: [
                ConsultationStatus.assigned.rawValue,
                ConsultationStatus.inProgress.rawValue
            ])
            .addSnapshotListener { snapshot, error in
                guard error == nil, let docs = snapshot?.documents else { return }
                let sessions = docs.compactMap { Self.decodeSession(id: $0.documentID, data: $0.data()) }
                Task { @MainActor in handler(sessions) }
            }
        #else
        handler(Self.sampleSessions)
        return nil
        #endif
    }

    public func assign(sessionId: String, to vet: UserProfile) async throws {
        #if canImport(FirebaseFirestore)
        guard vet.role == .vet else { return }
        try await sessionsCollection.document(sessionId).setData([
            "vetId": vet.id,
            "vetName": vet.displayName,
            "status": ConsultationStatus.assigned.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        #else
        throw ConsultationServiceError.unavailable
        #endif
    }

    public func updateStatus(sessionId: String, status: ConsultationStatus) async throws {
        #if canImport(FirebaseFirestore)
        try await sessionsCollection.document(sessionId).setData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        #else
        throw ConsultationServiceError.unavailable
        #endif
    }

    #if canImport(FirebaseFirestore)
    private static func decodeVet(document: QueryDocumentSnapshot) -> VetAvailability? {
        let data = document.data()
        guard let name = data["displayName"] as? String else { return nil }
        let specialties = data["specialties"] as? [String] ?? []
        let wait = data["queueEstimate"] as? Int
        let isOnline = (data["isOnline"] as? Bool) ?? true
        let photoURLString = data["photoURL"] as? String
        return VetAvailability(
            id: document.documentID,
            displayName: name,
            specialties: specialties,
            isOnline: isOnline,
            estimatedWaitMinutes: wait,
            photoURL: photoURLString.flatMap(URL.init(string:))
        )
    }

    private static func decodeSession(id: String, data: [String: Any]) -> ConsultationSession? {
        guard let ownerId = data["ownerId"] as? String else { return nil }
        let statusRaw = (data["status"] as? String) ?? ConsultationStatus.waiting.rawValue
        let status = ConsultationStatus(rawValue: statusRaw) ?? .waiting
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? createdAt
        let queuePosition = data["queuePosition"] as? Int
        let eta = data["etaMinutes"] as? Int
        return ConsultationSession(
            id: id,
            ownerId: ownerId,
            ownerName: data["ownerName"] as? String,
            vetId: data["vetId"] as? String ?? data["preferredVetId"] as? String,
            vetName: data["vetName"] as? String ?? data["preferredVetName"] as? String,
            status: status,
            lastMessagePreview: data["lastMessagePreview"] as? String,
            queuePosition: queuePosition,
            etaMinutes: eta,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    #endif

    private static var sampleVets: [VetAvailability] {
        [
            VetAvailability(id: "sample-vet-1", displayName: "Dr. Siri", specialties: ["Emergency"], estimatedWaitMinutes: 5),
            VetAvailability(id: "sample-vet-2", displayName: "Dr. Mali", specialties: ["Dermatology"], estimatedWaitMinutes: 12)
        ]
    }

    private static var sampleSessions: [ConsultationSession] {
        [
            ConsultationSession(
                id: "demo-session",
                ownerId: "demo-owner",
                ownerName: "Preview User",
                vetId: "sample-vet-1",
                vetName: "Dr. Siri",
                status: .waiting,
                createdAt: Date().addingTimeInterval(-600),
                updatedAt: Date().addingTimeInterval(-600)
            )
        ]
    }
}

