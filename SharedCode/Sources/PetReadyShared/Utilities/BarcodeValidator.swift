import Foundation

public enum BarcodeValidationError: Error {
    case invalidFormat
    case invalidChecksum
}

public struct BarcodeValidator {
    private static let regex = try! NSRegularExpression(pattern: "^PET-(DOG|CAT|RAB|OTH)-\\d{4}-\\d{6}-[0-9A-Z]{2}$")

    public init() {}

    public func validate(_ value: String) throws {
        let range = NSRange(location: 0, length: value.count)
        guard Self.regex.firstMatch(in: value, range: range) != nil else {
            throw BarcodeValidationError.invalidFormat
        }

        guard checksumIsValid(for: value) else {
            throw BarcodeValidationError.invalidChecksum
        }
    }

    private func checksumIsValid(for value: String) -> Bool {
        let alphanumerics = value.replacingOccurrences(of: "[^0-9A-Z]", with: "", options: .regularExpression)
        var sum = 0
        for character in alphanumerics {
            if let digit = character.wholeNumberValue {
                sum += digit
            } else if let scalar = character.unicodeScalars.first {
                sum += Int(scalar.value) - 55 // A=10
            }
        }
        return sum % 7 == 0
    }
}
