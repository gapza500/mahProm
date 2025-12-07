import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

#if canImport(FirebaseFirestore)
public typealias ChatMessagesListenerToken = ListenerRegistration
#else
public typealias ChatMessagesListenerToken = AnyObject
#endif

public final class ChatMessageService {
    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    private func messagesCollection(for sessionId: String) -> CollectionReference {
        db.collection("consultations").document(sessionId).collection("messages")
    }
    #endif

    public init() {}

    @discardableResult
    public func observeMessages(sessionId: String, handler: @escaping ([ChatMessage]) -> Void) -> ChatMessagesListenerToken? {
        #if canImport(FirebaseFirestore)
        return messagesCollection(for: sessionId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                guard error == nil, let docs = snapshot?.documents else { return }
                let messages: [ChatMessage] = docs.compactMap { doc in
                    guard let text = doc["text"] as? String,
                          let senderId = doc["senderId"] as? String,
                          let roleRaw = doc["senderRole"] as? String,
                          let role = UserType(rawValue: roleRaw) else { return nil }
                    let createdAt = (doc["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    return ChatMessage(
                        id: doc.documentID,
                        sessionId: sessionId,
                        senderId: senderId,
                        senderRole: role,
                        senderName: doc["senderName"] as? String,
                        text: text,
                        createdAt: createdAt
                    )
                }
                Task { @MainActor in handler(messages) }
            }
        #else
        handler([])
        return nil
        #endif
    }

    public func stopListening(_ token: ChatMessagesListenerToken?) {
        #if canImport(FirebaseFirestore)
        token?.remove()
        #endif
    }

    public func sendMessage(sessionId: String, sender: UserProfile, role: UserType, text: String) async throws {
        #if canImport(FirebaseFirestore)
        let payload: [String: Any] = [
            "senderId": sender.id,
            "senderRole": role.rawValue,
            "senderName": sender.displayName,
            "text": text,
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await messagesCollection(for: sessionId).addDocument(data: payload)
        #else
        throw ConsultationServiceError.unavailable
        #endif
    }
}
