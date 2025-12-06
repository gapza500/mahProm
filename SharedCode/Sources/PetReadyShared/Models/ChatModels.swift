import Foundation

public enum MessageType: String, Codable {
    case text
    case image
    case videoCall
}

public struct ChatMessage: Identifiable, Codable {
    public var id = UUID()
    public let text: String
    public let senderId: String
    public let receiverId: String
    public let timestamp: Date
    public let type: MessageType
    
    public var isMe: Bool { return senderId == "owner_001" }
    
    private enum CodingKeys: String, CodingKey {
        case text, senderId, receiverId, timestamp, type
    }
    
    public init(id: UUID = UUID(), text: String, senderId: String, receiverId: String, timestamp: Date, type: MessageType) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.type = type
    }
}