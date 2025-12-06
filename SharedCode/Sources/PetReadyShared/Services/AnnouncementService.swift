import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

public protocol AnnouncementServiceProtocol {
    func fetchAnnouncements(clinicId: UUID?) async -> [GovernmentAnnouncement]
    func createAnnouncement(_ announcement: GovernmentAnnouncement) async
}

public final class AnnouncementService: AnnouncementServiceProtocol {
    public static let shared = AnnouncementService()

    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    #endif

    private var cache: [GovernmentAnnouncement] = []

    public init() {
        cache = [
            GovernmentAnnouncement(
                title: "Emergency drill",
                content: "System-wide test. No action needed.",
                type: "system",
                priority: "info",
                targetAudience: "all"
            )
        ]
    }

    public func fetchAnnouncements(clinicId: UUID?) async -> [GovernmentAnnouncement] {
#if canImport(FirebaseFirestore)
        do {
            var query: Query = db.collection("announcements")
            if let clinicId {
                query = query.whereField("clinicId", isEqualTo: clinicId.uuidString)
            }
            let snapshot = try await query.getDocuments()
            let remote = snapshot.documents.compactMap { doc -> GovernmentAnnouncement? in
                guard let data = doc.data() else { return nil }
                guard let json = try? JSONSerialization.data(withJSONObject: data) else { return nil }
                return try? decoder.decode(GovernmentAnnouncement.self, from: json)
            }
            if !remote.isEmpty { return remote.sorted { $0.publishedAt > $1.publishedAt } }
        } catch {
            // ignore and use cache
        }
#endif
        return cache
            .filter { announcement in
                guard let cid = clinicId else { return true }
                return announcement.clinicId == nil || announcement.clinicId == cid
            }
            .sorted { $0.publishedAt > $1.publishedAt }
    }

    public func createAnnouncement(_ announcement: GovernmentAnnouncement) async {
        cache.append(announcement)
#if canImport(FirebaseFirestore)
        do {
            let data = try JSONSerialization.jsonObject(with: encoder.encode(announcement)) as? [String: Any] ?? [:]
            try await db.collection("announcements").document(announcement.id.uuidString).setData(data)
        } catch {
            // ignore errors in stub
        }
#endif
    }
}
