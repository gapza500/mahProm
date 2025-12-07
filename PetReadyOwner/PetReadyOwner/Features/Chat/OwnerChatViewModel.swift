import Foundation
import Combine
import PetReadyShared

@MainActor
final class OwnerChatViewModel: ObservableObject {
    @Published var availableVets: [VetAvailability] = []
    @Published var sessions: [ConsultationSession] = []
    @Published var isRequesting = false
    @Published var errorMessage: String?

    private let service: VetConsultationService
    private var listener: ConsultationListenerToken?
    private var currentOwnerId: String?

    init(service: VetConsultationService = VetConsultationService()) {
        self.service = service
    }

    func bind(to owner: UserProfile?) {
        guard let owner else {
            sessions = []
            availableVets = []
            currentOwnerId = nil
            return
        }
        if currentOwnerId != owner.id {
            currentOwnerId = owner.id
            attachListener(for: owner.id)
        }
        Task { [weak self] in await self?.refreshVets() }
    }

    func reloadSessions() {
        guard let ownerId = currentOwnerId else { return }
        attachListener(for: ownerId)
    }

    func refreshVets() async {
        do {
            let vets = try await service.fetchAvailableVets()
            availableVets = vets
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func requestConsultation(owner: UserProfile?, preferred vet: VetAvailability?) async {
        guard owner != nil else {
            errorMessage = ConsultationServiceError.ownerUnavailable.errorDescription
            return
        }
        guard let owner else { return }
        isRequesting = true
        defer { isRequesting = false }
        do {
            _ = try await service.requestConsultation(owner: owner, preferredVet: vet)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var activeSession: ConsultationSession? {
        sessions.first(where: { $0.isActive })
    }

    var historicalSessions: [ConsultationSession] {
        sessions.filter { !$0.isActive }
    }

    private func attachListener(for ownerId: String) {
        if let listener { service.stopListening(listener) }
        listener = service.observeOwnerSessions(ownerId: ownerId) { [weak self] sessions in
            self?.sessions = sessions
        }
    }
}
