import SwiftUI
import PetReadyShared

struct QueueMonitorView: View {
    @StateObject private var viewModel = VetQueueViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Waiting") {
                    ForEach(viewModel.waitingSessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.petName)
                                .font(.headline)
                            Text("Owner: \(session.ownerId.uuidString.prefix(6)) • ETA \(session.estimatedWaitMinutes)m")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button("Connect") {
                                    Task { await viewModel.accept(session) }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.isAssigning)
                                Button("Escalate") {
                                    Task { await viewModel.escalate(session) }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                Section("In consultation") {
                    ForEach(viewModel.activeSessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.petName)
                                .font(.headline)
                            Text("Talking to \(session.ownerId.uuidString.prefix(6))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button("Send quick reply") {
                                Task { await viewModel.sendQuickReply("ทีมดูแลพร้อมแล้วค่ะ", session: session) }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Queue")
            .task { await viewModel.load() }
        }
    }
}

@MainActor
final class VetQueueViewModel: ObservableObject {
    @Published var sessions: [ConsultationSession] = []
    @Published var isAssigning = false

    private let service: SmartVetCommunicationServiceProtocol
    private let clinicIdentity = ClinicIdentityStore.shared

    init(service: SmartVetCommunicationServiceProtocol = SmartVetCommunicationService.shared) {
        self.service = service
    }

    var waitingSessions: [ConsultationSession] {
        sessions.filter { $0.status == .waiting }
    }

    var activeSessions: [ConsultationSession] {
        sessions.filter { $0.status == .inConsultation }
    }

    func load() async {
        sessions = await service.sessions(forVet: clinicIdentity.clinicId)
        service.observeVetQueue { [weak self] updated in
            Task { @MainActor in self?.sessions = updated }
        }
    }

    func accept(_ session: ConsultationSession) async {
        isAssigning = true
        _ = await service.sendVetMessage("สวัสดีค่ะ Dr. \(session.vet.name) ค่ะ", in: session, vetId: clinicIdentity.clinicId)
        isAssigning = false
    }

    func escalate(_ session: ConsultationSession) async {
        _ = await service.sendVetMessage("กำลังยกระดับเคสให้ทีมพิเศษนะคะ", in: session, vetId: clinicIdentity.clinicId)
    }

    func sendQuickReply(_ text: String, session: ConsultationSession) async {
        _ = await service.sendVetMessage(text, in: session, vetId: clinicIdentity.clinicId)
    }
}
