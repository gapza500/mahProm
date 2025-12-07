import SwiftUI
import PetReadyShared

struct OwnerChatView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = OwnerChatViewModel()
    @State private var selectedVet: VetAvailability?
    @State private var activeChatSession: ConsultationSession?

    private var ownerProfile: UserProfile? { authService.profile }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    sessionSection
                    availableVetsSection
                    historySection
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Consult")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { refreshButton } }
            .refreshable {
                viewModel.reloadSessions()
                await viewModel.refreshVets()
            }
            .navigationDestination(item: $activeChatSession) { session in
                if let ownerProfile {
                    OwnerConsultConversationView(session: session, profile: ownerProfile)
                } else {
                    Text("Sign in to chat")
                }
            }
        }
        .task(id: ownerProfile?.id) {
            viewModel.bind(to: ownerProfile)
        }
        .onChange(of: viewModel.sessions) { sessions in
            guard let current = activeChatSession else { return }
            guard let updated = sessions.first(where: { $0.id == current.id }) else {
                activeChatSession = nil
                return
            }
            if updated.isActive {
                if updated != current { activeChatSession = updated }
            } else {
                activeChatSession = nil
            }
        }
        .alert("Consultation", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }

    private var sessionSection: some View {
        Group {
            if let session = viewModel.activeSession {
                ActiveConsultCard(session: session, onOpenChat: { activeChatSession = session })
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Need a vet now?")
                        .font(.title3.bold())
                        .foregroundStyle(DesignSystem.Colors.primaryText)
                    Text("Tell us what your pet needs help with and we'll connect you with the next available vet.")
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                    Button {
                        Task { await viewModel.requestConsultation(owner: ownerProfile, preferred: selectedVet ?? viewModel.availableVets.first) }
                    } label: {
                        Text(viewModel.isRequesting ? "Sending..." : "Consult now")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "FF9ECD")))
                    .foregroundStyle(.white)
                    .disabled(viewModel.isRequesting)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 24).fill(.regularMaterial))
            }
        }
    }

    private var availableVetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available vets")
                    .font(.headline)
                Spacer()
                if viewModel.isRequesting {
                    ProgressView().scaleEffect(0.7)
                }
            }
            if viewModel.availableVets.isEmpty {
                Text("No vets are online at the moment. We'll still queue your request when you tap Consult now.")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.availableVets) { vet in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(vet.displayName)
                                .font(.headline)
                            if vet.isOnline {
                                Circle().fill(Color.green).frame(width: 8, height: 8)
                                Text("Online")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                            Spacer()
                        }
                        if !vet.specialties.isEmpty {
                            Text(vet.specialties.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(DesignSystem.Colors.secondaryText)
                        }
                        if let wait = vet.estimatedWaitMinutes {
                            Text("~\(wait) min wait")
                                .font(.caption)
                                .foregroundStyle(DesignSystem.Colors.secondaryText)
                        }
                        Button {
                            selectedVet = vet
                            Task { await viewModel.requestConsultation(owner: ownerProfile, preferred: vet) }
                        } label: {
                            Text(selectedVet?.id == vet.id ? "Request sent" : "Ask \(vet.displayName)")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "FF9ECD"))
                        .disabled(viewModel.isRequesting)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.9)))
                }
            }
        }
    }

    private var historySection: some View {
        Group {
            if !viewModel.historicalSessions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("History")
                        .font(.headline)
                    ForEach(viewModel.historicalSessions, id: \.id) { session in
                        Button { activeChatSession = session } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.vetName ?? "Any available vet")
                                    .font(.subheadline.weight(.semibold))
                                Text(session.status.rawValue.capitalized)
                                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                                    .font(.caption)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.8)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    private var refreshButton: some View {
        Button {
            viewModel.reloadSessions()
            Task { await viewModel.refreshVets() }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
    }
}

private struct ActiveConsultCard: View {
    let session: ConsultationSession
    let onOpenChat: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You're in the queue")
                .font(.title3.bold())
            Text(queueLine)
                .font(.subheadline)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
            if let eta = session.etaMinutes {
                Label("Estimated wait: \(eta) min", systemImage: "clock")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
            Button("Open chat", action: onOpenChat)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "FF9ECD")))
                .foregroundStyle(.white)
                .disabled(!session.isActive)
                .opacity(session.isActive ? 1 : 0.5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.95)))
    }

    private var queueLine: String {
        if let vetName = session.vetName {
            return "Waiting for \(vetName)"
        }
        return "We'll assign the next available vet"
    }
}
