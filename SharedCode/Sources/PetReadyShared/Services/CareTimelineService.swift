import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

public enum CareTimelineServiceError: LocalizedError {
    case missingIdentifiers
    case firestoreUnavailable

    public var errorDescription: String? {
        switch self {
        case .missingIdentifiers:
            return "This pet is missing owner information."
        case .firestoreUnavailable:
            return "Cloud sync is not available in this build."
        }
    }
}

@MainActor
public protocol CareTimelineServiceProtocol {
    func loadEvents(ownerId: UUID?, petId: UUID?, limit: Int) async throws -> [CareEvent]
    func addEvent(_ event: CareEvent) async throws
    func updateStatus(eventId: UUID, status: CareEventStatus, outcomeNotes: String?) async throws
}

@MainActor
public final class CareTimelineService: CareTimelineServiceProtocol {
    #if canImport(FirebaseFirestore)
    private let collection = Firestore.firestore().collection("careEvents")
    #endif

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()

    public init() {}

    public func loadEvents(ownerId: UUID?, petId: UUID?, limit: Int = 50) async throws -> [CareEvent] {
        #if canImport(FirebaseFirestore)
        var query: Query = collection.order(by: "scheduledAt", descending: true)
        if let petId {
            query = query.whereField("petId", isEqualTo: petId.uuidString)
        } else if let ownerId {
            query = query.whereField("ownerId", isEqualTo: ownerId.uuidString)
        }
        query = query.limit(to: limit)
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap(decode(document:))
        #else
        throw CareTimelineServiceError.firestoreUnavailable
        #endif
    }

    public func addEvent(_ event: CareEvent) async throws {
        #if canImport(FirebaseFirestore)
        let data = try encode(event: event)
        try await collection.document(event.id.uuidString).setData(data, merge: true)
        #else
        throw CareTimelineServiceError.firestoreUnavailable
        #endif
    }

    public func updateStatus(eventId: UUID, status: CareEventStatus, outcomeNotes: String?) async throws {
        #if canImport(FirebaseFirestore)
        let update: [String: Any] = [
            "status": status.rawValue,
            "outcomeNotes": outcomeNotes ?? NSNull(),
            "updatedAt": Date().timeIntervalSince1970 * 1000
        ]
        try await collection.document(eventId.uuidString).setData(update, merge: true)
        #else
        throw CareTimelineServiceError.firestoreUnavailable
        #endif
    }

    #if canImport(FirebaseFirestore)
    private func encode(event: CareEvent) throws -> [String: Any] {
        let jsonObject = try JSONSerialization.jsonObject(with: encoder.encode(event))
        guard var dict = jsonObject as? [String: Any] else { return [:] }
        dict["id"] = event.id.uuidString
        dict["ownerId"] = event.ownerId.uuidString
        dict["petId"] = event.petId.uuidString
        dict["type"] = event.type.rawValue
        dict["status"] = event.status.rawValue
        return dict
    }

    private func decode(document: DocumentSnapshot) -> CareEvent? {
        guard var data = document.data() else { return nil }
        data["id"] = data["id"] ?? document.documentID
        return decode(dictionary: data)
    }

    private func decode(dictionary: [String: Any]) -> CareEvent? {
        guard
            let idString = dictionary["id"] as? String,
            let ownerIdString = dictionary["ownerId"] as? String,
            let petIdString = dictionary["petId"] as? String,
            let typeValue = dictionary["type"] as? String,
            let statusValue = dictionary["status"] as? String,
            let id = UUID(uuidString: idString),
            let ownerId = UUID(uuidString: ownerIdString),
            let petId = UUID(uuidString: petIdString),
            let type = CareEventType(rawValue: typeValue),
            let status = CareEventStatus(rawValue: statusValue)
        else {
            return nil
        }

        var normalized = dictionary
        normalized["id"] = id.uuidString
        normalized["ownerId"] = ownerId.uuidString
        normalized["petId"] = petId.uuidString
        guard
            JSONSerialization.isValidJSONObject(normalized),
            let data = try? JSONSerialization.data(withJSONObject: normalized),
            let decoded = try? decoder.decode(CareEvent.self, from: data)
        else {
            return nil
        }

        return decoded
    }
    #endif
}
