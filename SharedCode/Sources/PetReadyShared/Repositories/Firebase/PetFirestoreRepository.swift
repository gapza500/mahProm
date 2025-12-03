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
            guard let data = try? JSONSerialization.data(withJSONObject: doc.data()) else { return nil }
            return try? decoder.decode(Pet.self, from: data)
        }
    }

    public func save(pet: Pet) async throws {
        let jsonObject = try JSONSerialization.jsonObject(with: encoder.encode(pet))
        guard let dict = jsonObject as? [String: Any] else { return }
        try await collection.document(pet.id.uuidString).setData(dict)
    }
}
#endif
