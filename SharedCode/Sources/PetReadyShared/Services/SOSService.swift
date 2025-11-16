import Foundation

public protocol SOSServiceProtocol {
    func createCase(petId: UUID) async throws -> SOSCase
    func observeCases(update: @escaping (SOSCase) -> Void)
}

public final class SOSService: SOSServiceProtocol {
    private var observers: [(SOSCase) -> Void] = []

    public init() {}

    public func createCase(petId: UUID) async throws -> SOSCase {
        let caseItem = SOSCase(
            id: UUID(),
            requesterId: UUID(),
            riderId: nil,
            petId: petId,
            status: "created",
            createdAt: Date(),
            updatedAt: Date()
        )
        observers.forEach { $0(caseItem) }
        return caseItem
    }

    public func observeCases(update: @escaping (SOSCase) -> Void) {
        observers.append(update)
    }
}
