import SwiftUI
import PetReadyShared

struct AdminApprovalsScreen: View {
    #if canImport(FirebaseFirestore)
    @StateObject private var viewModel = PendingProfilesViewModel()
    #endif

    var body: some View {
        NavigationStack {
            #if canImport(FirebaseFirestore)
            ScrollView {
                VStack(spacing: 18) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding()
                    }
                    if viewModel.pendingProfiles.isEmpty && !viewModel.isLoading {
                        emptyState
                    } else {
                        ForEach(viewModel.pendingProfiles, id: \.id) { profile in
                            approvalCard(for: profile)
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("✅ Approvals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task { await viewModel.loadPending() }
                    }
                }
            }
            .task { await viewModel.loadPending() }
            .refreshable { await viewModel.loadPending() }
            #else
            Text("Firestore not available in this configuration.")
                .padding()
            #endif
        }
    }

    #if canImport(FirebaseFirestore)
    private func approvalCard(for profile: UserProfile) -> some View {
        cuteCard("\(icon(for: profile.role)) \(profile.displayName)", gradient: gradientFor(role: profile.role)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(profile.email).font(.subheadline)
                if let phone = profile.phone, !phone.isEmpty {
                    Text(phone).font(.caption).foregroundStyle(.secondary)
                }
                Text("Role: \(profile.role.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Button(role: .destructive) {
                        Task { await viewModel.reject(profile) }
                    } label: {
                        Text("Reject")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        Task { await viewModel.approve(profile) }
                    } label: {
                        Text("Approve")
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🎉").font(.largeTitle)
            Text("No pending approvals").font(.headline)
            Text("New rider, vet, clinic, and admin applications will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 24))
    }

    private func icon(for role: UserType) -> String {
        switch role {
        case .rider: return "🚴"
        case .vet, .clinic: return "👩‍⚕️"
        case .admin: return "🛡️"
        case .owner: return "🐶"
        case .tester: return "🧪"
        }
    }

    private func gradientFor(role: UserType) -> [Color] {
        switch role {
        case .rider:
            return [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]
        case .vet, .clinic:
            return [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]
        case .admin:
            return [Color(hex: "FFF3D4"), Color(hex: "FFE5A0")]
        case .owner, .tester:
            return [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]
        }
    }
    #endif  
}
