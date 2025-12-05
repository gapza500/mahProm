import Foundation

@MainActor
public protocol PetServiceProtocol {
    func loadPets() async throws -> [Pet]
    func addPet(_ pet: Pet) async throws
    func fetchPet(withBarcode code: String) async throws -> Pet?
    func claimPet(withBarcode code: String, ownerId: UUID) async throws -> Pet
}

@MainActor
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

    public func fetchPet(withBarcode code: String) async throws -> Pet? {
        try await repository.fetchPet(withBarcode: code.uppercased())
    }

    public func claimPet(withBarcode code: String, ownerId: UUID) async throws -> Pet {
        try await repository.claimPet(withBarcode: code.uppercased(), ownerId: ownerId)
    }
}
