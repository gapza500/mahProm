import Foundation
import SocketIO
import Combine

public class WebSocketManager: ObservableObject {
    
    // MARK: - Properties
    public static let shared = WebSocketManager()
    
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    
    @Published public var receivedMessage: (text: String, senderId: String, receiverId: String)?
    
    // MARK: - Lifecycle
    private init() {
        
        self.manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [
            .log(true),
            .compress
        ])
        self.socket = manager.defaultSocket
        setupSocketEvents()
    }
    
    // MARK: - Connection
    public func connect() {
        print("🔌 Connecting to WebSocket...")
        socket.connect()
    }
    
    public func disconnect() {
        print("🔌 Disconnecting...")
        socket.disconnect()
    }
    
    // MARK: - Event Handling
    private func setupSocketEvents() {
        socket.on(clientEvent: .connect) { data, ack in
            print("✅ Socket connected!")
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("❌ Socket disconnected")
        }
        
        
        socket.on("receiveMessage") { [weak self] data, ack in
            // แกะข้อมูล JSON แบบ Dictionary (ปลอดภัยกว่าใช้ Decodable ตรงนี้)
            if let dict = data[0] as? [String: Any],
               let text = dict["text"] as? String,
               let senderId = dict["senderId"] as? String,
               let receiverId = dict["receiverId"] as? String {
                
                print("📩 Message received: \(text)")
                
                
                DispatchQueue.main.async {
                    self?.receivedMessage = (text, senderId, receiverId)
                }
            }
        }
    }
    
    // MARK: - Message Sending
    
    public func sendMessage(text: String, senderId: String, receiverId: String) {
        let data: [String: Any] = [
            "text": text,
            "senderId": senderId,
            "receiverId": receiverId
        ]
        

        socket.emit("sendMessage", data)
    }
}
