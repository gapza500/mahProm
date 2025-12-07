import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore

public final class PetFirestoreRepository: PetRepositoryProtocol {
    private let collection = Firestore.firestore().collection("pets")
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

    public func fetchPets() async throws -> [Pet] {
        let snapshot = try await collection.getDocuments()
        return snapshot.documents.compactMap { decode(document: $0) }
    }

    public func save(pet: Pet) async throws {
        let payload = try encode(pet: pet)
        try await collection.document(pet.id.uuidString).setData(payload, merge: true)
    }

    public func fetchPet(withBarcode code: String) async throws -> Pet? {
        let normalized = code.uppercased()
        let snapshot = try await collection
            .whereField("barcodeId", isEqualTo: normalized)
            .limit(to: 1)
            .getDocuments()
        guard let document = snapshot.documents.first else { return nil }
        return decode(document: document)
    }

    public func claimPet(withBarcode code: String, ownerId: UUID) async throws -> Pet {
        let normalized = code.uppercased()
        let snapshot = try await collection
            .whereField("barcodeId", isEqualTo: normalized)
            .limit(to: 1)
            .getDocuments()
        guard let document = snapshot.documents.first else {
            throw PetRepositoryError.petNotFound
        }
        guard var pet = decode(document: document) else {
            throw PetRepositoryError.petNotFound
        }
        guard pet.barcodeId != nil else {
            throw PetRepositoryError.barcodeMissing
        }
        if let existingOwner = pet.ownerId, existingOwner != ownerId {
            throw PetRepositoryError.barcodeAlreadyClaimed
        }
        pet.ownerId = ownerId
        pet.status = "active"
        pet.updatedAt = Date()
        try await save(pet: pet)
        return pet
    }

    private func decode(document: DocumentSnapshot) -> Pet? {
        guard var raw = document.data() else { return nil }
        raw["id"] = raw["id"] ?? document.documentID
        let normalized = normalize(dictionary: raw)
        guard JSONSerialization.isValidJSONObject(normalized),
              let data = try? JSONSerialization.data(withJSONObject: normalized) else {
            return nil
        }
        return try? decoder.decode(Pet.self, from: data)
    }

    private func encode(pet: Pet) throws -> [String: Any] {
        let jsonObject = try JSONSerialization.jsonObject(with: encoder.encode(pet))
        guard var dict = jsonObject as? [String: Any] else { return [:] }
        dict["id"] = pet.id.uuidString
        if let barcode = dict["barcodeId"] as? String {
            dict["barcodeId"] = barcode.uppercased()
        }
        return dict
    }

    private func normalize(dictionary: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in dictionary {
            if let normalized = normalize(value: value) {
                result[key] = normalized
            }
        }
        return result
    }

    private func normalize(value: Any) -> Any? {
        switch value {
        case let timestamp as Timestamp:
            return timestamp.dateValue().timeIntervalSince1970 * 1000
        case let date as Date:
            return date.timeIntervalSince1970 * 1000
        case let dict as [String: Any]:
            return normalize(dictionary: dict)
        case let array as [Any]:
            return array.compactMap { normalize(value: $0) }
        case is NSNull:
            return nil
        default:
            return value
        }
    }
}
#endif
