#if canImport(CoreLocation)
import CoreLocation
#endif
import Foundation

public struct LocationSnapshot: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let coordinate: (latitude: Double, longitude: Double)
}

public protocol LocationServiceProtocol: AnyObject {
    func latestSnapshot() -> LocationSnapshot
    func requestMockRoute() -> [LocationSnapshot]
}

public final class LocationService: LocationServiceProtocol {
#if canImport(CoreLocation)
    private let manager = CLLocationManager()
#endif
    public init() {}

    public func latestSnapshot() -> LocationSnapshot {
        #if canImport(CoreLocation)
        let coordinate = manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
        return LocationSnapshot(title: "Bangkok HQ", subtitle: "Live location", coordinate: (coordinate.latitude, coordinate.longitude))
        #else
        return LocationSnapshot(title: "Bangkok HQ", subtitle: "Live location", coordinate: (13.7563, 100.5018))
        #endif
    }

    public func requestMockRoute() -> [LocationSnapshot] {
        [
            LocationSnapshot(title: "Owner Home", subtitle: "Pickup", coordinate: (13.7579, 100.4839)),
            LocationSnapshot(title: "On the way", subtitle: "ETA 12m", coordinate: (13.7602, 100.4956)),
            LocationSnapshot(title: "Clinic", subtitle: "Drop-off", coordinate: (13.7441, 100.5342))
        ]
    }
}
