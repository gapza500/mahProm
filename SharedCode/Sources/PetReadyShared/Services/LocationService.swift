import Foundation
#if canImport(CoreLocation)
import CoreLocation
#endif
#if canImport(MapKit)
import MapKit
#endif

public struct LocationSnapshot: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let coordinate: (latitude: Double, longitude: Double)
}

public protocol LocationServiceProtocol: AnyObject {
    func latestSnapshot() -> LocationSnapshot
    func requestMockRoute() -> [LocationSnapshot]
    func requestAuthorizationIfNeeded()
    func locationUpdates() -> AsyncStream<LocationSnapshot>
    var authorizationStatusDescription: String { get }
}

public final class LocationService: NSObject, LocationServiceProtocol {
#if canImport(CoreLocation)
    private let manager = CLLocationManager()
#endif
    private var cachedSnapshot = LocationSnapshot(
        title: "Unknown",
        subtitle: "Requesting location…",
        coordinate: (13.7563, 100.5018)
    )
    private var continuationStorage: [UUID: AsyncStream<LocationSnapshot>.Continuation] = [:]

    public override init() {
        super.init()
#if canImport(CoreLocation)
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25
#endif
    }

    public func requestAuthorizationIfNeeded() {
#if canImport(CoreLocation)
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
#endif
    }

    public func latestSnapshot() -> LocationSnapshot {
#if canImport(CoreLocation)
        if let coordinate = manager.location?.coordinate {
            cachedSnapshot = LocationSnapshot(
                title: "Live location",
                subtitle: formattedTimestamp(),
                coordinate: (coordinate.latitude, coordinate.longitude)
            )
        }
#endif
        return cachedSnapshot
    }

    public var authorizationStatusDescription: String {
#if canImport(CoreLocation)
        switch manager.authorizationStatus {
        case .notDetermined:
            return "Requesting permission"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways, .authorizedWhenInUse:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
#else
        return "Unavailable"
#endif
    }

    public func requestMockRoute() -> [LocationSnapshot] {
#if canImport(MapKit)
        if let current = manager.location?.coordinate {
            let offsets: [(String, Double, Double)] = [
                ("Owner Home", 0.002, -0.01),
                ("On the way", 0.004, 0.003),
                ("Clinic", -0.012, 0.025)
            ]
            return offsets.map { item in
                LocationSnapshot(
                    title: item.0,
                    subtitle: "Live route",
                    coordinate: (current.latitude + item.1, current.longitude + item.2)
                )
            }
        }
#endif
        return [
            LocationSnapshot(title: "Owner Home", subtitle: "Pickup", coordinate: (13.7579, 100.4839)),
            LocationSnapshot(title: "On the way", subtitle: "ETA 12m", coordinate: (13.7602, 100.4956)),
            LocationSnapshot(title: "Clinic", subtitle: "Drop-off", coordinate: (13.7441, 100.5342))
        ]
    }

    public func locationUpdates() -> AsyncStream<LocationSnapshot> {
        AsyncStream { continuation in
            let id = UUID()
            continuation.yield(latestSnapshot())
            continuation.onTermination = { [weak self] _ in
                self?.continuationStorage[id] = nil
            }
            continuationStorage[id] = continuation
            requestAuthorizationIfNeeded()
#if canImport(CoreLocation)
            manager.startUpdatingLocation()
#endif
        }
    }

    private func emit(snapshot: LocationSnapshot) {
        cachedSnapshot = snapshot
        continuationStorage.values.forEach { $0.yield(snapshot) }
    }

    private func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

#if canImport(CoreLocation)
extension LocationService: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        let snapshot = LocationSnapshot(
            title: "Live location",
            subtitle: formattedTimestamp(),
            coordinate: (coordinate.latitude, coordinate.longitude)
        )
        emit(snapshot: snapshot)
    }
}
#endif
