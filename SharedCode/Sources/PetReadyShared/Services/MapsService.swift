import Foundation
import CoreLocation

public enum MapsServiceError: Error {
    case invalidURL
}

public struct MapsService {
    public init() {}

    public func googleMapsURL(origin: CLLocationCoordinate2D?, destination: CLLocationCoordinate2D) throws -> URL {
        var components = URLComponents(string: "https://www.google.com/maps/dir/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: "\(destination.latitude),\(destination.longitude)"),
        ]

        if let origin {
            components?.queryItems?.append(URLQueryItem(name: "origin", value: "\(origin.latitude),\(origin.longitude)"))
        }

        components?.queryItems?.append(URLQueryItem(name: "travelmode", value: "driving"))

        guard let url = components?.url else { throw MapsServiceError.invalidURL }
        return url
    }
}
