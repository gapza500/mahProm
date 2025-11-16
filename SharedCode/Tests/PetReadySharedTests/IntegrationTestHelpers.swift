import XCTest
@testable import PetReadyShared

final class IntegrationTestHelpers: XCTestCase {
    func testCreateDemoUser() {
        let user = User(userType: .owner, displayName: "Test", phone: "000", email: "dev@petready")
        XCTAssertEqual(user.userType, .owner)
    }

    func testPetCreation() {
        let owner = UUID()
        let pet = Pet(ownerId: owner, species: .dog, name: "Buddy")
        XCTAssertEqual(pet.ownerId, owner)
    }
}
