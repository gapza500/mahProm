import Foundation

public struct LiveEvent: Identifiable, Sendable {
    public let id = UUID()
    public let description: String
    public let timestamp: Date
}

public protocol RealtimeSyncServiceProtocol: AnyObject, Sendable {
    func subscribe(to channel: String) async -> AsyncStream<LiveEvent>
}

public final class RealtimeSyncService: NSObject, RealtimeSyncServiceProtocol, @unchecked Sendable {
    private let socket: SocketConnection?
    private var continuationBuckets: [String: [UUID: AsyncStream<LiveEvent>.Continuation]] = [:]

    public override init() {
        if let url = Self.resolveURL() {
            socket = SocketConnection(url: url)
        } else {
            socket = nil
        }
        super.init()
        socket?.delegate = self
        socket?.connect()
    }

    public func subscribe(to channel: String) async -> AsyncStream<LiveEvent> {
        guard let socket else {
            return Self.fallbackStream(for: channel)
        }

        return AsyncStream { continuation in
            let id = UUID()
            continuation.yield(LiveEvent(description: "Listening to \(channel)…", timestamp: .init()))
            var listeners = continuationBuckets[channel] ?? [:]
            listeners[id] = continuation
            continuationBuckets[channel] = listeners
            continuation.onTermination = { [weak self] _ in
                self?.continuationBuckets[channel]?[id] = nil
            }

            sendSubscription(for: channel, socket: socket)
        }
    }

    private func sendSubscription(for channel: String, socket: SocketConnection) {
        let payload: [String: Any] = ["type": "subscribe", "channel": channel]
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let text = String(data: data, encoding: .utf8) {
            socket.send(text)
        }
    }

    private func broadcast(event: LiveEvent, to channel: String?) {
        guard let channel else { return }
        continuationBuckets[channel]?.values.forEach { $0.yield(event) }
    }

    private static func resolveURL() -> URL? {
        if let env = ProcessInfo.processInfo.environment["REALTIME_URL"],
           let envURL = URL(string: env) {
            return envURL
        }
        return URL(string: "wss://localhost:4000/realtime")
    }

    private static func fallbackStream(for channel: String) -> AsyncStream<LiveEvent> {
        AsyncStream { continuation in
            continuation.yield(LiveEvent(description: "Realtime offline for \(channel)", timestamp: .init()))
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                continuation.yield(LiveEvent(description: "Sample update (offline)", timestamp: .init()))
                continuation.finish()
            }
        }
    }
}

extension RealtimeSyncService: SocketConnectionDelegate {
    public func socketDidConnect() {
        guard let socket else { return }
        continuationBuckets.keys.forEach { channel in
            sendSubscription(for: channel, socket: socket)
        }
    }

    public func socketDidDisconnect(error: Error?) {
        let description = error?.localizedDescription ?? "Realtime disconnected"
        let event = LiveEvent(description: description, timestamp: .init())
        continuationBuckets.values.forEach { bucket in
            bucket.values.forEach { $0.yield(event) }
        }
    }

    public func socketDidReceive(message: String) {
        struct Payload: Decodable {
            let channel: String?
            let message: String?
        }

        if let data = message.data(using: .utf8),
           let payload = try? JSONDecoder().decode(Payload.self, from: data) {
            let event = LiveEvent(description: payload.message ?? message, timestamp: .init())
            broadcast(event: event, to: payload.channel)
        } else {
            let event = LiveEvent(description: message, timestamp: .init())
            broadcast(event: event, to: "broadcast")
        }
    }
}
