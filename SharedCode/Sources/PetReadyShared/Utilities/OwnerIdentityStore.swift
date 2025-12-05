import Foundation

public final class OwnerIdentityStore: ObservableObject {
    public static let shared = OwnerIdentityStore()

    @Published public private(set) var ownerId: UUID

    private let userDefaults: UserDefaults
    private let storageKey = "com.petready.owner.identity"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let stored = userDefaults.string(forKey: storageKey),
           let uuid = UUID(uuidString: stored) {
            ownerId = uuid
        } else {
            let newValue = UUID()
            ownerId = newValue
            userDefaults.set(newValue.uuidString, forKey: storageKey)
        }
    }

    public var ownerIdString: String { ownerId.uuidString }

    /// Generates a new identifier. Intended for QA / previews.
    public func regenerate(forTesting newId: UUID? = nil) {
        let identifier = newId ?? UUID()
        ownerId = identifier
        userDefaults.set(identifier.uuidString, forKey: storageKey)
    }
}
