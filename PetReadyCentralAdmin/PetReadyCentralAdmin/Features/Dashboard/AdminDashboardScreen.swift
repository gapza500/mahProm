import SwiftUI
import PetReadyShared

struct AdminDashboardScreen: View {
    @StateObject private var viewModel = AdminDependencies.shared.petListViewModel
    @State private var didTriggerInitialLoad = false
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    metrics
                    cuteCard("🚨 Emergency Care", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        cuteRow(icon: "🆘", title: "SOS cases", subtitle: "2 little ones need help now", badge: "Active", badgeColor: Color(hex: "FF9ECD"))
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "👨‍⚕️", title: "Online vets & helpers", subtitle: "45 vets • 28 riders ready to help")
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "☀️", title: "Weather alert", subtitle: "Hot day in Bangkok - keep pets cool!")
                    }
                    cuteCard("📢 Announcements", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteRow(icon: "📣", title: "Send announcement", subtitle: "Broadcast to all pet parents", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "📅", title: "Scheduled messages", subtitle: "2 announcements tomorrow", badge: "2", badgeColor: Color(hex: "A0D8F1"))
                    }
                    recentPetRegistrations
                }
                .padding()
            }
            .refreshable { await reload() }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Pet Care Central")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {} label: {
                        HStack(spacing: 6) {
                            Text("📢")
                            Text("Broadcast").font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")], startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 8, y: 4)
                    }
                }
            }
            .task { await reloadIfNeeded() }
        }
    }

    private func reloadIfNeeded() async {
        guard !didTriggerInitialLoad else { return }
        didTriggerInitialLoad = true
        await reload()
    }

    private func reload() async {
        isLoading = true
        await viewModel.loadPets()
        isLoading = false
    }

    private var hero: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("🌟").font(.title)
                        Text("National Pet Dashboard")
                            .font(.title2.bold())
                            .foregroundStyle(DesignSystem.Colors.onAccentText)
                    }
                    Text("Keeping all furry friends safe & happy!")
                        .font(.subheadline)
                        .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.95))
                    HStack(spacing: 12) {
                        Label("5min", systemImage: "clock.fill")
                        Text("•")
                        Label("99% happy", systemImage: "heart.fill")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.9))
                    .padding(.top, 4)
                }
                Spacer()
                Text("🐶").font(.system(size: 70))
            }
            .padding(24)
            .background(
                ZStack {
                    LinearGradient(colors: [Color(hex: "FFB5D8"), Color(hex: "A0D8F1")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Circle().fill(.white.opacity(0.15)).frame(width: 200, height: 200).offset(x: 80, y: -60).blur(radius: 50)
                    Circle().fill(.white.opacity(0.1)).frame(width: 150, height: 150).offset(x: -70, y: 40).blur(radius: 40)
                }
            )
            HStack(spacing: 20) {
                ForEach(0..<5) { _ in
                    Text("🐾").font(.caption2).opacity(0.4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "FFB5D8").opacity(0.3), radius: 20, y: 10)
    }

    private var metrics: some View {
        HStack(spacing: 14) {
            cuteMetricTile(emoji: "🆘", title: "SOS", value: "2", subtitle: "Active", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
            cuteMetricTile(emoji: "✅", title: "Approvals", value: "8", subtitle: "Waiting", colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")])
            cuteMetricTile(emoji: "🔔", title: "Alerts", value: "1", subtitle: "Active", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
        }
    }

    private func cuteMetricTile(emoji: String, title: String, value: String, subtitle: String, colors: [Color]) -> some View {
        VStack(spacing: 12) {
            Text(emoji).font(.system(size: 32))
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(LinearGradient(colors: colors.map { $0.opacity(0.8) }, startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(spacing: 2) {
                Text(subtitle).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Text(title).font(.caption2.weight(.medium)).foregroundStyle(.tertiary).textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(.white)
                RoundedRectangle(cornerRadius: 24).fill(
                    LinearGradient(colors: colors.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(colors[0].opacity(0.2), lineWidth: 2))
        .shadow(color: colors[0].opacity(0.15), radius: 12, y: 6)
    }

    private var recentPetRegistrations: some View {
        cuteCard("🐾 Recent Pet Registrations", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView().tint(Color(hex: "FF9ECD"))
                    Text("Fetching the latest pets…").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else if viewModel.pets.isEmpty {
                VStack(spacing: 8) {
                    Text("🐶").font(.largeTitle)
                    Text("No new registrations yet").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                PetRegistrationsTable(pets: viewModel.pets).padding(.top, 4)
            }
        }
    }
}
