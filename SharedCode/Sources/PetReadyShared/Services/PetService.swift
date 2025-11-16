import Foundation

public protocol PetServiceProtocol {
    func loadPets() async throws -> [Pet]
    func addPet(_ pet: Pet) async throws
}

public final class PetService: PetServiceProtocol {
    private let repository: PetRepositoryProtocol

    public init(repository: PetRepositoryProtocol) {
        self.repository = repository
    }

    public func loadPets() async throws -> [Pet] {
        try await repository.fetchPets()
    }

    public func addPet(_ pet: Pet) async throws {
        try await repository.save(pet: pet)
    }
}
