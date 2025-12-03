import Foundation

public enum PetRepositoryFactory {
    public static func makeRepository() -> PetRepositoryProtocol {
        #if canImport(FirebaseFirestore)
        if NSClassFromString("FIRFirestore") != nil {
            return PetFirestoreRepository()
        }
        #endif
        return PetRepository()
    }
}
