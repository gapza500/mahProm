import Foundation
import Combine
import PetReadyShared

@MainActor
final class VetQueueViewModel: ObservableObject {
    @Published private(set) var waitingSessions: [ConsultationSession] = []
    @Published private(set) var activeSessions: [ConsultationSession] = []
    @Published var isUpdating = false
    @Published var errorMessage: String?

    private let service: VetConsultationService
    private var waitingListener: ConsultationListenerToken?
    private var activeListener: ConsultationListenerToken?
    private var currentVetId: String?

    init(service: VetConsultationService = VetConsultationService()) {
        self.service = service
        waitingListener = service.observeWaitingQueue { [weak self] sessions in
            self?.waitingSessions = sessions
        }
    }

    func bind(to vetProfile: UserProfile?) {
        guard let vetProfile, vetProfile.role == .vet else {
            activeSessions = []
            currentVetId = nil
            stopListeningToActiveSessions()
            return
        }
        if currentVetId != vetProfile.id {
            currentVetId = vetProfile.id
            stopListeningToActiveSessions()
            activeListener = service.observeActiveSessions(forVetId: vetProfile.id) { [weak self] sessions in
                self?.activeSessions = sessions
            }
        }
    }

    func accept(session: ConsultationSession, vetProfile: UserProfile?) async {
        guard let vet = vetProfile else {
            errorMessage = ConsultationServiceError.unavailable.errorDescription
            return
        }
        isUpdating = true
        defer { isUpdating = false }
        do {
            try await service.assign(sessionId: session.id, to: vet)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func complete(session: ConsultationSession) async {
        isUpdating = true
        defer { isUpdating = false }
        do {
            try await service.updateStatus(sessionId: session.id, status: .completed)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stopListeningToActiveSessions() {
        guard let token = activeListener else { return }
        Task { @MainActor in service.stopListening(token) }
        activeListener = nil
    }

}
