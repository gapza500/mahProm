import Foundation

public protocol AuthServiceProtocol: AnyObject {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }

    func login(phone: String, otp: String) async throws -> User
    func verifyOTP(code: String) async throws -> Bool
    func logout()
}

public final class AuthService: ObservableObject, AuthServiceProtocol {
    @Published public private(set) var currentUser: User?
    @Published public private(set) var isAuthenticated = false

    private let apiClient: APIClientProtocol
    private let keychain: KeychainService
    private let tokenKey = "authToken"

    public init(apiClient: APIClientProtocol, keychain: KeychainService = .shared) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    public func login(phone: String, otp: String) async throws -> User {
        struct LoginRequest: Encodable { let phone: String; let otp: String }
        struct LoginResponse: Decodable { let token: String; let user: User }

        let payload = try JSONEncoder().encode(LoginRequest(phone: phone, otp: otp))
        let endpoint = Endpoint(path: "auth/login", method: .post, body: payload)
        let response = try await apiClient.request(endpoint, response: LoginResponse.self)
        keychain.save(token: response.token, for: tokenKey)

        await MainActor.run {
            currentUser = response.user
            isAuthenticated = true
        }
        return response.user
    }

    public func verifyOTP(code: String) async throws -> Bool {
        struct VerifyRequest: Encodable { let code: String }
        struct VerifyResponse: Decodable { let valid: Bool }

        let payload = try JSONEncoder().encode(VerifyRequest(code: code))
        let endpoint = Endpoint(path: "auth/otp", method: .post, body: payload)
        let response = try await apiClient.request(endpoint, response: VerifyResponse.self)
        return response.valid
    }

    public func logout() {
        keychain.delete(key: tokenKey)
        currentUser = nil
        isAuthenticated = false
    }

    public var token: String? {
        keychain.token(for: tokenKey)
    }
}
