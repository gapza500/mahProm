import Foundation

public enum PetRepositoryError: LocalizedError, Equatable {
    case petNotFound
    case barcodeAlreadyClaimed
    case barcodeMissing

    public var errorDescription: String? {
        switch self {
        case .petNotFound:
            return "We couldn't find a pet for that barcode."
        case .barcodeAlreadyClaimed:
            return "That barcode is already linked to another owner."
        case .barcodeMissing:
            return "This pet doesn't have a barcode assigned yet."
        }
    }
}

public protocol PetRepositoryProtocol {
    func fetchPets() async throws -> [Pet]
    func save(pet: Pet) async throws
    func fetchPet(withBarcode code: String) async throws -> Pet?
    func claimPet(withBarcode code: String, ownerId: UUID) async throws -> Pet
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

    public func fetchPet(withBarcode code: String) async throws -> Pet? {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let normalized = code.uppercased()
                let pet = self.inMemoryStore.first { $0.barcodeId?.uppercased() == normalized }
                continuation.resume(returning: pet)
            }
        }
    }

    public func claimPet(withBarcode code: String, ownerId: UUID) async throws -> Pet {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let normalized = code.uppercased()
                guard let index = self.inMemoryStore.firstIndex(where: { $0.barcodeId?.uppercased() == normalized }) else {
                    continuation.resume(throwing: PetRepositoryError.petNotFound)
                    return
                }
                var pet = self.inMemoryStore[index]
                guard pet.barcodeId != nil else {
                    continuation.resume(throwing: PetRepositoryError.barcodeMissing)
                    return
                }
                if let existingOwner = pet.ownerId, existingOwner != ownerId {
                    continuation.resume(throwing: PetRepositoryError.barcodeAlreadyClaimed)
                    return
                }
                pet.ownerId = ownerId
                pet.status = "active"
                pet.updatedAt = Date()
                self.inMemoryStore[index] = pet
                continuation.resume(returning: pet)
            }
        }
    }
}
