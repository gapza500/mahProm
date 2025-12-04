import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore

@MainActor
public final class PendingProfilesViewModel: ObservableObject {
    @Published public private(set) var pendingProfiles: [UserProfile] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let collection = Firestore.firestore().collection("users")

    public init() {}

    public func loadPending() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await collection.whereField("status", isEqualTo: UserApprovalStatus.pending.rawValue).getDocuments()
            pendingProfiles = snapshot.documents.compactMap { UserProfile(document: $0) }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func approve(_ profile: UserProfile) async {
        await update(profile: profile, newStatus: .approved)
    }

    public func reject(_ profile: UserProfile) async {
        await update(profile: profile, newStatus: .rejected)
    }

    private func update(profile: UserProfile, newStatus: UserApprovalStatus) async {
        do {
            try await collection.document(profile.id).setData(["status": newStatus.rawValue], merge: true)
            pendingProfiles.removeAll { $0.id == profile.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
