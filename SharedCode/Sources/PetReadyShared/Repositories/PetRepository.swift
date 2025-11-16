import Foundation

public protocol PetRepositoryProtocol {
    func fetchPets() async throws -> [Pet]
    func save(pet: Pet) async throws
}

public final class PetRepository: PetRepositoryProtocol {
    private var inMemoryStore: [Pet] = []
    private let queue = DispatchQueue(label: "com.petready.petRepository", qos: .userInitiated)

    public init() {}

    public func fetchPets() async throws -> [Pet] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { continuation.resume(returning: self.inMemoryStore) }
        }
    }

    public func save(pet: Pet) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                if let index = self.inMemoryStore.firstIndex(where: { $0.id == pet.id }) {
                    self.inMemoryStore[index] = pet
                } else {
                    self.inMemoryStore.append(pet)
                }
                continuation.resume()
            }
        }
    }
}
