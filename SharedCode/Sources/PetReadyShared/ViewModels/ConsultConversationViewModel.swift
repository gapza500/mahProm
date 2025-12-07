import Foundation
import Combine

@MainActor
public final class ConsultConversationViewModel: ObservableObject {
    @Published public private(set) var messages: [ChatMessage] = []
    @Published public var draft: String = ""
    @Published public private(set) var isSending = false
    @Published public private(set) var errorMessage: String?

    public let session: ConsultationSession
    public let senderProfile: UserProfile
    public let senderRole: UserType

    private let service: ChatMessageService
    private var listener: ChatMessagesListenerToken?

    public init(
        session: ConsultationSession,
        senderProfile: UserProfile,
        senderRole: UserType,
        service: ChatMessageService = ChatMessageService()
    ) {
        self.session = session
        self.senderProfile = senderProfile
        self.senderRole = senderRole
        self.service = service
        listener = service.observeMessages(sessionId: session.id) { [weak self] messages in
            self?.messages = messages
        }
    }

    deinit {
        if let listener { service.stopListening(listener) }
    }

    public func send() async {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSending = true
        defer { isSending = false }
        do {
            try await service.sendMessage(sessionId: session.id, sender: senderProfile, role: senderRole, text: trimmed)
            draft = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func clearError() {
        errorMessage = nil
    }
}
