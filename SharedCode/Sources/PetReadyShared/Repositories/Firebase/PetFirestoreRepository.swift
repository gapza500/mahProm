import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore

public final class PetFirestoreRepository: PetRepositoryProtocol {
    private let collection = Firestore.firestore().collection("pets")
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() {}

    public func fetchPets() async throws -> [Pet] {
        let snapshot = try await collection.getDocuments()
        return snapshot.documents.compactMap { doc in
            decode(document: doc)
        }
    }

    public func save(pet: Pet) async throws {
        let jsonObject = try JSONSerialization.jsonObject(with: encoder.encode(pet))
        guard let dict = jsonObject as? [String: Any] else { return }
        try await collection.document(pet.id.uuidString).setData(dict)
    }

    public func fetchPet(withBarcode code: String) async throws -> Pet? {
        let snapshot = try await collection.whereField("barcodeId", isEqualTo: code).limit(to: 1).getDocuments()
        guard let document = snapshot.documents.first else { return nil }
        return decode(document: document)
    }

    public func claimPet(withBarcode code: String, ownerId: UUID) async throws -> Pet {
        let snapshot = try await collection.whereField("barcodeId", isEqualTo: code).limit(to: 1).getDocuments()
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
        guard let data = try? JSONSerialization.data(withJSONObject: document.data() ?? [:]) else { return nil }
        return try? decoder.decode(Pet.self, from: data)
    }
}
#endif
