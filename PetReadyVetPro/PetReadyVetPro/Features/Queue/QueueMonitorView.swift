import SwiftUI
import PetReadyShared

struct QueueMonitorView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var activeChatSession: ConsultationSession?
    @StateObject private var viewModel = VetQueueViewModel()

    private var vetProfile: UserProfile? { authService.profile }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    waitingCard
                    activeCard
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Queue")
            .navigationDestination(item: $activeChatSession) { session in
                if let vetProfile {
                    VetConsultConversationView(session: session, profile: vetProfile)
                } else {
                    Text("Sign in to chat")
                }
            }
        }
        .task(id: vetProfile?.id) {
            viewModel.bind(to: vetProfile)
        }
        .alert("Consultations", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }

    private var waitingCard: some View {
        vetCuteCard("Waiting", gradient: [Color(hex: "FFE5A0").opacity(0.2), Color.white]) {
            if viewModel.waitingSessions.isEmpty {
                Text("No owners are waiting right now.")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            } else {
                ForEach(viewModel.waitingSessions) { session in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.ownerName ?? "Owner")
                            .font(.headline)
                        Text(session.createdAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryText)
                        HStack {
                            Button {
                                Task { await viewModel.accept(session: session, vetProfile: vetProfile) }
                            } label: {
                                Text("Accept case")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: "8C6FF7"))
                            .disabled(viewModel.isUpdating)

                            Button { activeChatSession = session } label: {
                                Image(systemName: "bubble.right")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                    Divider()
                }
            }
        }
    }

    private var activeCard: some View {
        vetCuteCard("In Progress", gradient: [Color(hex: "98D8AA").opacity(0.2), Color.white]) {
            if viewModel.activeSessions.isEmpty {
                Text("No active consultations.")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            } else {
                ForEach(viewModel.activeSessions) { session in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.ownerName ?? "Owner")
                            .font(.headline)
                        Text("Status: \(session.status.rawValue.capitalized)")
                            .foregroundStyle(DesignSystem.Colors.secondaryText)
                            .font(.caption)
                        HStack {
                            Button {
                                activeChatSession = session
                            } label: {
                                Text("Open chat")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: "8C6FF7"))

                            Button {
                                Task { await viewModel.complete(session: session) }
                            } label: {
                                Text("Mark done")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color(hex: "677D6A"))
                            .disabled(viewModel.isUpdating)
                        }
                    }
                    .padding(.vertical, 4)
                    Divider()
                }
            }
        }
    }
}
