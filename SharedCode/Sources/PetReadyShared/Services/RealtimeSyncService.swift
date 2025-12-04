import Foundation

public struct LiveEvent: Identifiable, Sendable {
    public let id = UUID()
    public let description: String
    public let timestamp: Date
}

public protocol RealtimeSyncServiceProtocol: AnyObject {
    func subscribe(to channel: String) async -> AsyncStream<LiveEvent>
}

public final class RealtimeSyncService: RealtimeSyncServiceProtocol {
    public init() {}

    public func subscribe(to channel: String) async -> AsyncStream<LiveEvent> {
        AsyncStream { continuation in
            continuation.yield(LiveEvent(description: "Listening to \(channel)…", timestamp: .init()))
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                continuation.yield(LiveEvent(description: "Sample update pushed", timestamp: .init()))
                continuation.finish()
            }
        }
    }
}
