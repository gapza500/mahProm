import Foundation
import CoreLocation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

public protocol ClinicServiceProtocol: Sendable {
    func listNearbyClinics(latitude: Double, longitude: Double, radiusKm: Double) async throws -> [Clinic]
    func clinic(withId id: UUID) async throws -> Clinic?
}

public final class ClinicService: ClinicServiceProtocol, @unchecked Sendable {
    public static let shared = ClinicService()

    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    private let decoder = JSONDecoder()
    #endif

    public init() {}

    public func listNearbyClinics(latitude: Double, longitude: Double, radiusKm: Double = 20) async throws -> [Clinic] {
        let anchor = Coordinate(latitude: latitude, longitude: longitude)
#if canImport(FirebaseFirestore)
        let snapshot = try await db.collection("clinics").getDocuments()
        var clinics = snapshot.documents.compactMap { decodeClinic(document: $0, anchor: anchor) }
        clinics = clinics.map { clinic in
            var mutable = clinic
            mutable.distanceKm = anchor.distanceKm(to: clinic.coordinate)
            return mutable
        }
        return clinics
            .filter { ($0.distanceKm ?? .infinity) <= radiusKm }
            .sorted { ($0.distanceKm ?? .infinity) < ($1.distanceKm ?? .infinity) }
#else
        return sampleClinics(anchor: anchor, radiusKm: radiusKm)
#endif
    }

    public func clinic(withId id: UUID) async throws -> Clinic? {
#if canImport(FirebaseFirestore)
        let doc = try await db.collection("clinics").document(id.uuidString).getDocument()
        return decodeClinic(document: doc, anchor: nil)
#else
        return sampleClinics(anchor: Coordinate(latitude: 13.7563, longitude: 100.5018), radiusKm: 100).first { $0.id == id }
#endif
    }

#if canImport(FirebaseFirestore)
    private func decodeClinic(document: DocumentSnapshot, anchor: Coordinate?) -> Clinic? {
        guard let data = document.data() else { return nil }
        guard let json = try? JSONSerialization.data(withJSONObject: data) else { return nil }
        var clinic = try? decoder.decode(Clinic.self, from: json)
        if var mutable = clinic, let anchor {
            mutable.distanceKm = anchor.distanceKm(to: mutable.coordinate)
            clinic = mutable
        }
        return clinic
    }
#endif

    private func sampleClinics(anchor: Coordinate, radiusKm: Double) -> [Clinic] {
        let clinics: [Clinic] = [
            Clinic(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000101") ?? UUID(),
                name: "PetWell Siam",
                address: "123 Sukhumvit, Bangkok",
                coordinate: Coordinate(latitude: 13.745, longitude: 100.532),
                specialty: "Emergency",
                rating: 4.8,
                reviewCount: 120,
                services: ["Emergency", "Dermatology", "CT Scan"],
                operatingHours: "24/7",
                verificationStatus: "approved",
                phone: "+66 2 123 4567",
                email: "hello@petwell.co",
                website: "https://petwell.co"
            ),
            Clinic(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000102") ?? UUID(),
                name: "Chiang Mai Animal Wellness",
                address: "42 Nimman, Chiang Mai",
                coordinate: Coordinate(latitude: 18.795, longitude: 98.968),
                specialty: "General",
                rating: 4.6,
                reviewCount: 85,
                services: ["Surgery", "Dentistry", "Wellness"],
                operatingHours: "08:00 - 22:00",
                verificationStatus: "approved",
                phone: "+66 53 123 987",
                email: "contact@cmwellness.co",
                website: "https://cmwellness.co"
            ),
            Clinic(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000103") ?? UUID(),
                name: "Phuket Pet Emergency",
                address: "Beach Road 87, Phuket",
                coordinate: Coordinate(latitude: 7.880, longitude: 98.392),
                specialty: "Emergency",
                rating: 4.5,
                reviewCount: 66,
                services: ["Emergency", "Imaging"],
                operatingHours: "24/7",
                verificationStatus: "approved",
                phone: "+66 76 555 444",
                email: "sos@phuketpet.co",
                website: "https://phuketpet.co"
            )
        ]

        return clinics
            .map { clinic -> Clinic in
                var updated = clinic
                updated.distanceKm = anchor.distanceKm(to: clinic.coordinate)
                return updated
            }
            .filter { ($0.distanceKm ?? .infinity) <= radiusKm }
            .sorted { ($0.distanceKm ?? .infinity) < ($1.distanceKm ?? .infinity) }
    }
}
