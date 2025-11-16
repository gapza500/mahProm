import XCTest
@testable import PetReadyShared

final class BarcodeValidatorTests: XCTestCase {
    func testValidBarcodePasses() throws {
        let validator = BarcodeValidator()
        let valid = "PET-DOG-1234-123456-AD"
        XCTAssertNoThrow(try validator.validate(valid))
    }

    func testInvalidFormatFails() {
        let validator = BarcodeValidator()
        XCTAssertThrowsError(try validator.validate("INVALID"))
    }
}
