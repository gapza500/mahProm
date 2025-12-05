import Foundation

public struct BarcodeGenerator {
    private let validator = BarcodeValidator()

    public init() {}

    public func generate(for species: Pet.Species) throws -> String {
        let speciesCode: String
        switch species {
        case .dog: speciesCode = "DOG"
        case .cat: speciesCode = "CAT"
        case .rabbit: speciesCode = "RAB"
        case .bird: speciesCode = "OTH"
        case .other: speciesCode = "OTH"
        }

        for _ in 0..<50 {
            let blockOne = String(format: "%04d", Int.random(in: 0..<10_000))
            let blockTwo = String(format: "%06d", Int.random(in: 0..<1_000_000))
            let suffix = randomSuffix()
            let candidate = "PET-\(speciesCode)-\(blockOne)-\(blockTwo)-\(suffix)"
            do {
                try validator.validate(candidate)
                return candidate
            } catch {
                continue
            }
        }
        throw BarcodeValidationError.invalidChecksum
    }

    private func randomSuffix() -> String {
        let characters = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let first = characters.randomElement() ?? "A"
        let second = characters.randomElement() ?? "B"
        return "\(first)\(second)"
    }
}
