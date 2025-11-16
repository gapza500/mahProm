import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public var queryItems: [URLQueryItem]
    public var body: Data?
    public var headers: [String: String]

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        headers: [String: String] = [:]
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
    }
}

public protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, response: T.Type) async throws -> T
}

public final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func request<T>(_ endpoint: Endpoint, response: T.Type) async throws -> T where T : Decodable {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        if request.httpBody != nil && endpoint.headers["Content-Type"] == nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        endpoint.headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(T.self, from: data)
    }
}
