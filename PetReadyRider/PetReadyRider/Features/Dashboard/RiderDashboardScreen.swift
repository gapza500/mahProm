import SwiftUI
import PetReadyShared

struct RiderDashboardScreen: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var walletStore = WalletStore.shared
    @StateObject private var jobsViewModel = RiderJobsViewModel(service: SOSServiceFactory.make(), locationService: LocationService())

    private var riderName: String {
        authService.profile?.displayName ?? "PetReady Rider"
    }

    private var riderId: UUID {
        if let id = authService.profile?.id, let uuid = UUID(uuidString: id) {
            return uuid
        }
        return UUID()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileCard
                    completionSummaryCard
                    activeMissionCard
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Dashboard")
        }
        .task { await jobsViewModel.start(riderId: riderId) }
    }

    private var profileCard: some View {
        riderCuteCard("Rider", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            HStack(spacing: 16) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "A0D8F1"), Color(hex: "98D8AA")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 70, height: 70)
                    .overlay(Text("🚴").font(.title))
                VStack(alignment: .leading, spacing: 6) {
                    Text(riderName)
                        .font(.title3.weight(.semibold))
                    Text("PetReady Rider")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label("Profile complete", systemImage: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(Color(hex: "98D8AA"))
                }
                Spacer()
                NavigationLink {
                    RiderProfileScreen()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var completionSummaryCard: some View {
        riderCuteCard("Progress", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            HStack(spacing: 20) {
                progressTile(label: "Completed jobs", value: "\(walletStore.completedJobsCount)")
                progressTile(label: "Wallet", value: "฿\(Int(walletStore.balance))")
            }
        }
    }

    private func progressTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 6)
    }

    private var activeMissionCard: some View {
        riderCuteCard("Active mission", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
            if let active = jobsViewModel.activeCase {
                RiderJobSummaryView(caseItem: active)
                Divider().padding(.vertical, 8)
                NavigationLink {
                    RiderNavigationScreen(caseId: active.id, viewModel: jobsViewModel)
                } label: {
                    Label("Open navigation", systemImage: "location.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "FF9ECD"), in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                }
                .buttonStyle(.plain)
            } else {
                Text("You have no active SOS missions.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
