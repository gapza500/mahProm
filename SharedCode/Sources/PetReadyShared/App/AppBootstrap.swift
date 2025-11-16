#if canImport(FirebaseCore)
import FirebaseCore
#endif

public enum AppBootstrap {
    public static func configureFirebaseIfNeeded() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif
    }
}
