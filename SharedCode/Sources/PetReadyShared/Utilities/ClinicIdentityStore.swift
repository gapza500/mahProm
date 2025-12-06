import Foundation

public final class ClinicIdentityStore: ObservableObject {
    public static let shared = ClinicIdentityStore()

    @Published public private(set) var clinicId: UUID

    private let userDefaults: UserDefaults
    private let storageKey = "com.petready.clinic.identity"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let stored = userDefaults.string(forKey: storageKey), let uuid = UUID(uuidString: stored) {
            clinicId = uuid
        } else {
            let newValue = UUID()
            clinicId = newValue
            userDefaults.set(newValue.uuidString, forKey: storageKey)
        }
    }

    public func regenerate(forTesting newId: UUID? = nil) {
        let identifier = newId ?? UUID()
        clinicId = identifier
        userDefaults.set(identifier.uuidString, forKey: storageKey)
    }
}
