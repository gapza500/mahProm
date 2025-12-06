import SwiftUI
import PetReadyShared

struct OwnerChatView: View {
    @StateObject private var viewModel = OwnerChatViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Available vets") {
                    if viewModel.availableVets.isEmpty {
                        Text("No vets online right now.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.availableVets) { vet in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(vet.name).font(.headline)
                                    Spacer()
                                    Text("\(vet.waitMinutes) min")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("\(vet.specialty) – \(vet.hospital)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Button("Consult now") {
                                    Task { await viewModel.startConsultation(with: vet) }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.isStartingSession)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("My sessions") {
                    if viewModel.sessions.isEmpty {
                        Text("You haven't started any consultations yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink {
                                OwnerConsultationDetailView(session: session, viewModel: viewModel)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(session.vet.name).font(.headline)
                                        Spacer()
                                        Text(session.status.readableLabel)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text("Pet: \(session.petName)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chat")
            .task { await viewModel.load() }
        }
    }
}

struct OwnerConsultationDetailView: View {
    let session: ConsultationSession
    @ObservedObject var viewModel: OwnerChatViewModel
    @State private var messageText = ""

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages(for: session)) { message in
                            HStack {
                                if message.senderType == .owner {
                                    Spacer()
                                    bubble(text: message.text, color: Color(hex: "A0D8F1"))
                                } else {
                                    bubble(text: message.text, color: Color(hex: "FFE5F1"))
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages(for: session).count) { _ in
                    if let last = viewModel.messages(for: session).last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("Type a message", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task {
                        await viewModel.sendOwnerMessage(messageText, in: session)
                        messageText = ""
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(session.vet.name)
    }

    private func bubble(text: String, color: Color) -> some View {
        Text(text)
            .padding(10)
            .background(color.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }
}

@MainActor
final class OwnerChatViewModel: ObservableObject {
    @Published var availableVets: [VetAvailability] = []
    @Published var sessions: [ConsultationSession] = []
    @Published var isStartingSession = false
    @Published var pets: [Pet] = []

    private let service: SmartVetCommunicationServiceProtocol
    private let identityStore: OwnerIdentityStore
    private let petService: PetServiceProtocol

    var ownerId: UUID { identityStore.ownerId }

    init(
        service: SmartVetCommunicationServiceProtocol = SmartVetCommunicationService.shared,
        identityStore: OwnerIdentityStore = .shared,
        petService: PetServiceProtocol = PetService(repository: PetRepositoryFactory.makeRepository())
    ) {
        self.service = service
        self.identityStore = identityStore
        self.petService = petService
    }

    func load() async {
        availableVets = await service.listAvailableVets()
        sessions = await service.sessions(forOwner: ownerId)
        if let loadedPets = try? await petService.loadPets() {
            pets = loadedPets
        }
        service.observeSessions(forOwner: ownerId) { [weak self] updated in
            Task { @MainActor in
                self?.sessions = updated
            }
        }
    }

    func startConsultation(with vet: VetAvailability) async {
        guard !isStartingSession else { return }
        isStartingSession = true
        let petName = pets.first?.name ?? "My Pet"
        let session = await service.requestConsultation(vet: vet, ownerId: ownerId, petName: petName)
        sessions.append(session)
        isStartingSession = false
    }

    func messages(for session: ConsultationSession) -> [Message] {
        service.messages(for: session.conversationId)
    }

    func sendOwnerMessage(_ text: String, in session: ConsultationSession) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        _ = await service.sendOwnerMessage(text, in: session, ownerId: ownerId)
        objectWillChange.send()
    }
}

private extension ConsultationSession.Status {
    var readableLabel: String {
        switch self {
        case .waiting: return "Waiting"
        case .connecting: return "Connecting"
        case .inConsultation: return "In Consultation"
        case .escalated: return "Escalated"
        case .completed: return "Completed"
        }
    }
}
