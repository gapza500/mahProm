import Foundation
import Starscream

public protocol SocketConnectionDelegate: AnyObject {
    func socketDidConnect()
    func socketDidDisconnect(error: Error?)
    func socketDidReceive(message: String)
}

public final class SocketConnection: Starscream.WebSocketDelegate {
    private let socket: Starscream.WebSocket
    public weak var delegate: SocketConnectionDelegate?

    public init(url: URL) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
    }

    public func connect() {
        socket.connect()
    }

    public func disconnect() {
        socket.disconnect()
    }

    public func send(_ text: String) {
        socket.write(string: text)
    }

    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected:
            delegate?.socketDidConnect()
        case .disconnected(let reason, let code):
            let error = NSError(domain: "Socket", code: Int(code), userInfo: [NSLocalizedDescriptionKey: reason])
            delegate?.socketDidDisconnect(error: error)
        case .text(let message):
            delegate?.socketDidReceive(message: message)
        case .error(let error):
            delegate?.socketDidDisconnect(error: error)
        default:
            break
        }
    }
}
