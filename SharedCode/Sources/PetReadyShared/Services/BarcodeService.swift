import Foundation

public final class BarcodeService {
    private let validator = BarcodeValidator()

    public init() {}

    public func claim(code: String, for pet: Pet) async throws -> Barcode {
        try validator.validate(code)
        return Barcode(
            petId: pet.id,
            codeText: code,
            type: code.contains("QR") ? "qr" : "code128"
        )
    }
}
