import Foundation

public protocol SmartVetCommunicationServiceProtocol: AnyObject {
    func listAvailableVets() async -> [VetAvailability]
    func requestConsultation(vet: VetAvailability, ownerId: UUID, petName: String) async -> ConsultationSession
    func sessions(forOwner ownerId: UUID) async -> [ConsultationSession]
    func sessions(forVet vetId: UUID) async -> [ConsultationSession]
    func observeSessions(forOwner ownerId: UUID, update: @escaping ([ConsultationSession]) -> Void)
    func observeVetQueue(update: @escaping ([ConsultationSession]) -> Void)
    func messages(for conversationId: UUID) -> [Message]
    func sendOwnerMessage(_ text: String, in session: ConsultationSession, ownerId: UUID) async -> Message
    func sendVetMessage(_ text: String, in session: ConsultationSession, vetId: UUID) async -> Message
}

public final class SmartVetCommunicationService: SmartVetCommunicationServiceProtocol {
    public static let shared = SmartVetCommunicationService()

    private var vets: [VetAvailability] = []
    private var sessions: [ConsultationSession] = []
    private var messages: [UUID: [Message]] = [:]

    private var ownerObservers: [UUID: ([ConsultationSession]) -> Void] = [:]
    private var vetObservers: [UUID: ([ConsultationSession]) -> Void] = [:]
    private var queueObservers: [UUID: ([ConsultationSession]) -> Void] = [:]

    private let queue = DispatchQueue(label: "com.petready.smartVetService", qos: .userInitiated)

    public init() {
        vets = [
            VetAvailability(
                name: "Dr. Siri Chantarat",
                hospital: "Bangkok Animal Hospital",
                specialty: "Emergency & Trauma",
                waitMinutes: 5,
                rating: 4.9,
                languages: ["TH", "EN"],
                status: .available
            ),
            VetAvailability(
                name: "Dr. Nina Wattanaporn",
                hospital: "Chiang Mai Pet Wellness",
                specialty: "Dermatology",
                waitMinutes: 12,
                rating: 4.7,
                languages: ["TH"],
                status: .busy
            ),
            VetAvailability(
                name: "Dr. Lert Tan",
                hospital: "Phuket Vet Hub",
                specialty: "General Practice",
                waitMinutes: 3,
                rating: 4.8,
                languages: ["TH", "EN", "CN"],
                status: .available
            )
        ]
    }

    public func listAvailableVets() async -> [VetAvailability] {
        vets
    }

    public func requestConsultation(vet: VetAvailability, ownerId: UUID, petName: String) async -> ConsultationSession {
        await withCheckedContinuation { continuation in
            queue.async {
                var session = ConsultationSession(
                    vet: vet,
                    ownerId: ownerId,
                    petName: petName,
                    estimatedWaitMinutes: max(2, vet.waitMinutes),
                    escalatesAt: Date().addingTimeInterval(15 * 60)
                )
                self.sessions.append(session)
                let greeting = Message(
                    id: UUID(),
                    conversationId: session.conversationId,
                    senderId: vet.id,
                    senderType: .vet,
                    text: "สวัสดีค่ะ นี่คือ \(vet.name) จะเชื่อมต่อใน \(session.estimatedWaitMinutes) นาที",
                    createdAt: Date()
                )
                self.messages[session.conversationId, default: []].append(greeting)
                self.notifyObservers(forOwner: ownerId)
                self.notifyQueueObservers()
                continuation.resume(returning: session)
                self.scheduleAutoReply(for: session)
            }
        }
    }

    public func sessions(forOwner ownerId: UUID) async -> [ConsultationSession] {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: self.sessions.filter { $0.ownerId == ownerId })
            }
        }
    }

    public func sessions(forVet vetId: UUID) async -> [ConsultationSession] {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: self.sessions.filter { $0.vet.id == vetId })
            }
        }
    }

    public func observeSessions(forOwner ownerId: UUID, update: @escaping ([ConsultationSession]) -> Void) {
        ownerObservers[ownerId] = update
        Task { let data = await sessions(forOwner: ownerId); update(data) }
    }

    public func observeVetQueue(update: @escaping ([ConsultationSession]) -> Void) {
        let token = UUID()
        queueObservers[token] = update
        update(sessions)
    }

    public func messages(for conversationId: UUID) -> [Message] {
        messages[conversationId] ?? []
    }

    public func sendOwnerMessage(_ text: String, in session: ConsultationSession, ownerId: UUID) async -> Message {
        await sendMessage(text, in: session, from: ownerId, senderType: .owner)
    }

    public func sendVetMessage(_ text: String, in session: ConsultationSession, vetId: UUID) async -> Message {
        await sendMessage(text, in: session, from: vetId, senderType: .vet)
    }

    // MARK: - Private helpers
    private func sendMessage(_ text: String, in session: ConsultationSession, from sender: UUID, senderType: UserType) async -> Message {
        await withCheckedContinuation { continuation in
            queue.async {
                let message = Message(
                    id: UUID(),
                    conversationId: session.conversationId,
                    senderId: sender,
                    senderType: senderType,
                    text: text,
                    createdAt: Date()
                )
                self.messages[session.conversationId, default: []].append(message)
                self.notifyMessageUpdate(for: session.conversationId, ownerId: session.ownerId)
                continuation.resume(returning: message)
            }
        }
    }

    private func scheduleAutoReply(for session: ConsultationSession) {
        queue.asyncAfter(deadline: .now() + 5) {
            var updatedSession = session
            updatedSession.status = .inConsultation
            self.replaceSession(updatedSession)
            let reply = Message(
                id: UUID(),
                conversationId: session.conversationId,
                senderId: session.vet.id,
                senderType: .vet,
                text: "กำลังออนไลน์แล้วค่ะ เล่าอาการของ \(session.petName) เพิ่มเติมได้เลยนะคะ",
                createdAt: Date()
            )
            self.messages[session.conversationId, default: []].append(reply)
            self.notifyMessageUpdate(for: session.conversationId, ownerId: session.ownerId)
        }
    }

    private func replaceSession(_ updated: ConsultationSession) {
        if let index = sessions.firstIndex(where: { $0.id == updated.id }) {
            sessions[index] = updated
            notifyObservers(forOwner: updated.ownerId)
            notifyQueueObservers()
        }
    }

    private func notifyObservers(forOwner ownerId: UUID) {
        let data = sessions.filter { $0.ownerId == ownerId }
        ownerObservers[ownerId]?(data)
    }

    private func notifyQueueObservers() {
        queueObservers.values.forEach { $0(sessions) }
    }

    private func notifyMessageUpdate(for conversationId: UUID, ownerId: UUID) {
        notifyObservers(forOwner: ownerId)
        notifyQueueObservers()
    }
}
