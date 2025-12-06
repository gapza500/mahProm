import SwiftUI
import PetReadyShared

struct VetDashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    vetHeroCard
                    metricGrid
                    queueCard
                    quickActionsCard
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Dashboard")
        }
    }

    private var vetHeroCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Good Morning, Dr. Siri! 👩‍⚕️")
                    .font(.title2.bold())
                    .foregroundStyle(DesignSystem.Colors.onAccentText)
                Text("You’re on a 4.2⭐ response streak")
                    .font(.subheadline)
                    .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.95))
                HStack(spacing: 8) {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                    Text("•")
                    Text("Reply < 5 min")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.85))
                .padding(.top, 4)
            }
            Spacer()
        }
        .padding(24)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "A0D8F1"), Color(hex: "FFB5D8")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .offset(x: 100, y: -40)
                    .blur(radius: 30)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "A0D8F1").opacity(0.4), radius: 16, y: 8)
    }

    private var metricGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            vetCuteStatusTile(icon: "🗓️", title: "Today", subtitle: "11", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
            vetCuteStatusTile(icon: "⚡️", title: "Queue", subtitle: "3", colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")])
            vetCuteStatusTile(icon: "⭐️", title: "Rating", subtitle: "4.9", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
        }
    }

    private var queueCard: some View {
        vetCuteCard("Consultation Queue", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            ForEach(0..<3, id: \.self) { idx in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Owner #\(idx + 241)")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("Fluffy – Itchy skin")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Join") {}
                        .font(.caption.bold())
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "FF9ECD"), in: Capsule())
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 4, y: 2)
                }
                .padding(.vertical, 6)
                if idx < 2 { Divider() }
            }
        }
    }

    private var quickActionsCard: some View {
        vetCuteCard("Quick Actions", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
            NavigationLink {
                ClinicAppointmentsView()
            } label: {
                vetCuteActionRow(icon: "🗓️", title: "Appointments", subtitle: "Approve requests", showChevron: true)
            }
            Divider().padding(.leading, 50)
            NavigationLink {
                ClinicAnnouncementsView()
            } label: {
                vetCuteActionRow(icon: "📢", title: "Announcements", subtitle: "Clinic-targeted alerts", showChevron: true)
            }
            Divider().padding(.leading, 50)
            vetCuteActionRow(icon: "💬", title: "Tele-chat room", subtitle: "Reply instantly", showChevron: true)
            Divider().padding(.leading, 50)
            vetCuteActionRow(icon: "💊", title: "Prescription", subtitle: "Send PDF/Photo", showChevron: true)
            Divider().padding(.leading, 50)
            vetCuteActionRow(icon: "📹", title: "Video Handoff", subtitle: "Switch to video", badge: "Pro", badgeColor: Color(hex: "98D8AA"), showChevron: true)
        }
    }
}

struct ClinicAnnouncementsView: View {
    @State private var announcements: [GovernmentAnnouncement] = []
    @State private var isLoading = false

    private let service: AnnouncementServiceProtocol = AnnouncementService.shared
    private let clinicStore: ClinicIdentityStore = .shared

    var body: some View {
        List {
            Section("Targeted to this clinic") {
                if isLoading {
                    ProgressView("Loading…")
                } else if announcements.isEmpty {
                    Text("No announcements yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(announcements) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title).font(.headline)
                            Text(item.content).font(.caption).foregroundStyle(.secondary)
                            Text(item.publishedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("Clinic Alerts")
        .task { await load() }
    }

    private func load() async {
        let clinicId = clinicStore.clinicId
        await MainActor.run { isLoading = true }
        let items = await service.fetchAnnouncements(clinicId: clinicId)
        await MainActor.run {
            announcements = items
            isLoading = false
        }
    }
}
