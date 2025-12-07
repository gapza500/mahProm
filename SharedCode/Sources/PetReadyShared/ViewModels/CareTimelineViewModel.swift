import Foundation

@MainActor
public final class CareTimelineViewModel: ObservableObject {
    @Published public private(set) var events: [CareEvent] = []
    @Published public private(set) var isLoading = false
    @Published public var errorMessage: String?

    private let service: CareTimelineServiceProtocol
    private var lastOwnerId: UUID?
    private var lastPetId: UUID?
    private var lastLimit: Int = 50

    public init(service: CareTimelineServiceProtocol) {
        self.service = service
    }

    public func loadEvents(ownerId: UUID? = nil, petId: UUID? = nil, limit: Int = 50) async {
        isLoading = true
        defer { isLoading = false }
        lastOwnerId = ownerId
        lastPetId = petId
        lastLimit = limit
        do {
            events = try await service.loadEvents(ownerId: ownerId, petId: petId, limit: limit)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func refresh() async {
        await loadEvents(ownerId: lastOwnerId, petId: lastPetId, limit: lastLimit)
    }

    public func addEvent(_ event: CareEvent) async {
        do {
            try await service.addEvent(event)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func updateStatus(for event: CareEvent, status: CareEventStatus, outcomeNotes: String? = nil) async {
        do {
            try await service.updateStatus(eventId: event.id, status: status, outcomeNotes: outcomeNotes)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
