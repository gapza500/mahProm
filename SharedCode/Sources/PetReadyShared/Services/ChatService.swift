import Foundation

public final class ChatService: SocketConnectionDelegate {
    private let socketConnection: SocketConnection
    private var onMessage: ((Message) -> Void)?

    public init(socketConnection: SocketConnection) {
        self.socketConnection = socketConnection
        self.socketConnection.delegate = self
    }

    public func connect(onMessage: @escaping (Message) -> Void) {
        self.onMessage = onMessage
        socketConnection.connect()
    }

    public func disconnect() {
        socketConnection.disconnect()
    }

    public func send(message: Message) {
        if let encoded = try? JSONEncoder().encode(message),
           let string = String(data: encoded, encoding: .utf8) {
            socketConnection.send(string)
        }
    }

    public func socketDidConnect() {}

    public func socketDidDisconnect(error: Error?) {
        if let error {
            print("Socket disconnected: \(error)")
        }
    }

    public func socketDidReceive(message: String) {
        guard let data = message.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Message.self, from: data) else { return }
        onMessage?(decoded)
    }
}
