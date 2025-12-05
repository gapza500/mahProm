import XCTest
@testable import PetReadyShared

final class IntegrationTestHelpers: XCTestCase {
    func testCreateDemoUser() {
        let user = User(userType: .owner, displayName: "Test", phone: "000", email: "dev@petready")
        XCTAssertEqual(user.userType, .owner)
    }

    func testPetCreation() {
        let owner = UUID()
        let assigned = Pet(ownerId: owner, species: .dog, name: "Buddy")
        XCTAssertEqual(assigned.ownerId, owner)

        let unassigned = Pet(species: .cat, name: "Mittens")
        XCTAssertNil(unassigned.ownerId)
    }

    func testBarcodeClaimFlow() async throws {
        let repository = PetRepository()
        let service = PetService(repository: repository)
        let barcode = "PET-DOG-0001-000001-AA"
        let pending = Pet(
            ownerId: nil,
            species: .dog,
            name: "Pixel",
            barcodeId: barcode,
            status: "awaiting_claim"
        )
        try await service.addPet(pending)

        let ownerId = UUID()
        let claimed = try await service.claimPet(withBarcode: barcode, ownerId: ownerId)
        XCTAssertEqual(claimed.ownerId, ownerId)
        XCTAssertEqual(claimed.status, "active")

        do {
            _ = try await service.claimPet(withBarcode: barcode, ownerId: UUID())
            XCTFail("Claiming the same barcode with another owner should throw")
        } catch let error as PetRepositoryError {
            XCTAssertEqual(error, .barcodeAlreadyClaimed)
        }
    }
}
