import SwiftUI
import PetReadyShared

struct AdminAnnouncementsScreen: View {
    @State private var announcements: [GovernmentAnnouncement] = []
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var clinicIdText: String = ""
    @State private var isSaving = false

    private let service: AnnouncementServiceProtocol = AnnouncementService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("📝 New Announcement", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("Title", text: $title)
                            TextField("Content", text: $content, axis: .vertical)
                                .lineLimit(3, reservesSpace: true)
                            TextField("Target clinic UUID (optional)", text: $clinicIdText)
                                .textInputAutocapitalization(.never)
                                .font(.caption)
                            Button(isSaving ? "Sending…" : "Send") {
                                Task { await sendAnnouncement() }
                            }
                            .disabled(title.isEmpty || content.isEmpty || isSaving)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "A0D8F1"), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                        }
                    }

                    cuteCard("🔔 Live Announcements", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        if announcements.isEmpty {
                            Text("No announcements yet.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(announcements) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(item.title).font(.headline)
                                        Spacer()
                                        if let clinicId = item.clinicId {
                                            Text("Clinic")
                                                .font(.caption2.weight(.bold))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(hex: "FFE5A0"), in: Capsule())
                                                .overlay(
                                                    Text(clinicId.uuidString.prefix(4))
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                )
                                        } else {
                                            Text("All")
                                                .font(.caption2.weight(.bold))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(hex: "A0D8F1"), in: Capsule())
                                        }
                                    }
                                    Text(item.content).font(.caption)
                                    Text(item.publishedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 8)
                                if item.id != announcements.last?.id {
                                    Divider().padding(.leading, 8)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("🔔 Alerts")
            .task { await loadAnnouncements() }
        }
    }

    private func sendAnnouncement() async {
        guard !title.isEmpty, !content.isEmpty else { return }
        await MainActor.run { isSaving = true }
        let clinicId = UUID(uuidString: clinicIdText.trimmingCharacters(in: .whitespacesAndNewlines))
        let announcement = GovernmentAnnouncement(
            title: title,
            content: content,
            priority: "high",
            targetAudience: "all",
            clinicId: clinicId
        )
        await service.createAnnouncement(announcement)
        await loadAnnouncements()
        await MainActor.run {
            title = ""
            content = ""
            clinicIdText = ""
            isSaving = false
        }
    }

    private func loadAnnouncements() async {
        let items = await service.fetchAnnouncements(clinicId: nil)
        await MainActor.run { announcements = items }
    }
}
