
#if canImport(FirebaseAuth)
import FirebaseAuth
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
#if os(iOS)
import UIKit
#endif
import Foundation

public protocol AuthServiceProtocol: AnyObject {
    var role: UserType? { get }
    var isAuthenticated: Bool { get }
    var errorDescription: String? { get }
    var profile: UserProfile? { get }
    var isProfileLoading: Bool { get }

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, displayName: String, role: UserType, status: UserApprovalStatus, phone: String?) async throws
    func signInWithGoogle() async throws
    func signOut() throws
    func refreshRole() async
}

@MainActor
public final class AuthService: ObservableObject, AuthServiceProtocol {
    @Published public private(set) var firebaseUser: FirebaseAuth.User?
    @Published public private(set) var role: UserType?
    @Published public private(set) var isAuthenticated = false
    @Published public private(set) var errorDescription: String?
    @Published public private(set) var profile: UserProfile?
    @Published public private(set) var isProfileLoading = false

    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private let isPreviewMode: Bool
#if canImport(FirebaseFirestore)
    private let usersCollection = Firestore.firestore().collection("users")
#endif

    public init(previewRole: UserType? = nil) {
        self.isPreviewMode = previewRole != nil
        if let previewRole {
            self.role = previewRole
            self.isAuthenticated = true
            return
        }

        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { await self?.handleAuthChange(user: user) }
        }
        Task { await handleAuthChange(user: Auth.auth().currentUser) }
    }

    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    public func signIn(email: String, password: String) async throws {
        do {
            _ = try await Auth.auth().signIn(withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            await MainActor.run {
                self.errorDescription = nil
            }
        } catch {
            await MainActor.run {
                self.errorDescription = error.localizedDescription
                self.isAuthenticated = false
            }
            throw error
        }
    }

    public func signUp(
        email: String,
        password: String,
        displayName: String,
        role: UserType,
        status: UserApprovalStatus = .pending,
        phone: String? = nil
    ) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let result = try await Auth.auth().createUser(withEmail: trimmedEmail, password: password)
            #if canImport(FirebaseFirestore)
            var profilePayload = UserProfile(
                id: result.user.uid,
                displayName: displayName,
                email: trimmedEmail,
                phone: phone,
                role: role,
                status: status
            ).toFirestoreData()
            profilePayload["createdAt"] = FieldValue.serverTimestamp()
            try await usersCollection.document(result.user.uid).setData(profilePayload, merge: true)
            #endif
            await MainActor.run {
                self.errorDescription = nil
            }
        } catch {
            await MainActor.run {
                self.errorDescription = error.localizedDescription
            }
            throw error
        }
    }

    public func signInWithGoogle() async throws {
        #if canImport(GoogleSignIn)
        guard let presenter = AuthService.presentingViewController() else {
            throw AuthError.missingPresenter
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.missingGoogleToken
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            _ = try await Auth.auth().signIn(with: credential)
            await MainActor.run { self.errorDescription = nil }
        } catch {
            await MainActor.run { self.errorDescription = error.localizedDescription }
            throw error
        }
        #else
        throw AuthError.providerUnavailable
        #endif
    }

    public func signOut() throws {
        try Auth.auth().signOut()
        Task { await MainActor.run {
            self.role = nil
            self.errorDescription = nil
            self.profile = nil
        } }
    }

    public func refreshRole() async {
        guard let user = Auth.auth().currentUser else { return }
        await fetchRole(for: user, forceRefresh: true)
    }

    private func handleAuthChange(user: FirebaseAuth.User?) async {
        await MainActor.run {
            self.firebaseUser = user
            self.isAuthenticated = (user != nil) || self.isPreviewMode
            if user == nil {
                self.role = self.isPreviewMode ? self.role : nil
                self.profile = nil
            }
        }
        guard let user else { return }
        await fetchRole(for: user, forceRefresh: false)
        await fetchProfile(for: user)
    }

    private func fetchRole(for user: FirebaseAuth.User, forceRefresh: Bool) async {
        do {
            let tokenResult = try await user.getIDTokenResult(forcingRefresh: forceRefresh)
            let parsedRole = Self.extractRole(from: tokenResult.claims)
            await MainActor.run {
                self.role = parsedRole
                self.errorDescription = nil
            }
        } catch {
            await MainActor.run {
                self.role = nil
                self.errorDescription = error.localizedDescription
            }
        }
    }

    private func fetchProfile(for user: FirebaseAuth.User) async {
        #if canImport(FirebaseFirestore)
        await MainActor.run { self.isProfileLoading = true }
        defer { Task { await MainActor.run { self.isProfileLoading = false } } }

        do {
            let snapshot = try await usersCollection.document(user.uid).getDocument()
            let profile = UserProfile(document: snapshot)
            await MainActor.run {
                self.profile = profile
                if let profileRole = profile?.role, profileRole != self.role {
                    self.role = profileRole
                }
            }
        } catch {
            await MainActor.run {
                self.errorDescription = error.localizedDescription
            }
        }
        #endif
    }

    private static func extractRole(from claims: [String: Any]) -> UserType? {
        if let singleRole = claims["role"] as? String, let parsed = UserType(rawValue: singleRole) {
            return parsed
        }
        if let roles = claims["roles"] as? [String] {
            for entry in roles {
                if let parsed = UserType(rawValue: entry) {
                    return parsed
                }
            }
        }
        return nil
    }

    #if os(iOS)
    private static func presentingViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        return topViewController(from: root)
    }

    private static func topViewController(from controller: UIViewController) -> UIViewController {
        if let nav = controller as? UINavigationController, let visible = nav.visibleViewController {
            return topViewController(from: visible)
        }
        if let tab = controller as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(from: selected)
        }
        if let presented = controller.presentedViewController {
            return topViewController(from: presented)
        }
        return controller
    }
    #endif

    enum AuthError: LocalizedError {
        case missingPresenter
        case missingGoogleToken
        case providerUnavailable

        var errorDescription: String? {
            switch self {
            case .missingPresenter:
                return "Unable to find a screen to present Google Sign-In."
            case .missingGoogleToken:
                return "Google Sign-In did not return a valid token."
            case .providerUnavailable:
                return "Google Sign-In is not available on this platform."
            }
        }
    }
}

#else
import Foundation

@MainActor
public final class AuthService: ObservableObject {
    @Published public private(set) var role: UserType? = .tester
    @Published public private(set) var isAuthenticated = true
    @Published public private(set) var errorDescription: String?
    @Published public private(set) var profile: UserProfile? = nil
    @Published public private(set) var isProfileLoading = false

    public init(previewRole: UserType? = .tester) {
        role = previewRole
    }

    public func signIn(email: String, password: String) async throws {}
    public func signUp(email: String, password: String, displayName: String, role: UserType, status: UserApprovalStatus, phone: String?) async throws {}
    public func signInWithGoogle() async throws {}
    public func signOut() throws {}
    public func refreshRole() async {}
}
#endif
