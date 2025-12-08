import Foundation
import Combine
import PetReadyShared

@MainActor
final class OwnerHomeViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var events: [CareEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var ownerDisplayName: String?

    private let petService: PetServiceProtocol
    private let careService: CareTimelineServiceProtocol

    private var currentOwnerId: UUID?

    init(
        petService: PetServiceProtocol = PetService(repository: PetRepositoryFactory.makeRepository()),
        careService: CareTimelineServiceProtocol = CareTimelineService()
    ) {
        self.petService = petService
        self.careService = careService
    }

    func refresh(ownerProfile: UserProfile?) async {
        guard
            let ownerProfile,
            let ownerId = UUID(uuidString: ownerProfile.id)
        else {
            await MainActor.run {
                pets = []
                events = []
                currentOwnerId = nil
                ownerDisplayName = nil
            }
            return
        }

        if currentOwnerId == ownerId, !pets.isEmpty { return }
        currentOwnerId = ownerId
        ownerDisplayName = ownerProfile.displayName

        isLoading = true
        defer { isLoading = false }

        do {
            let allPets = try await petService.loadPets()
            let ownedPets = allPets.filter { $0.ownerId == ownerId }
            let careItems = try await careService.loadEvents(ownerId: ownerId, petId: nil, limit: 50)

            await MainActor.run {
                pets = ownedPets
                events = careItems
                errorMessage = nil
            }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }

    var ownerFirstName: String {
        if let name = ownerDisplayName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return name.components(separatedBy: " ").first ?? name
        }
        return "Friend"
    }

    var petSummary: String {
        guard !pets.isEmpty else { return "Add your pet to keep them safe" }
        let names = pets.prefix(2).map { $0.name }
        if pets.count == 1 { return "\(names.first ?? "Your pet") is safe today" }
        if pets.count == 2 { return "\(names[0]) & \(names[1]) are safe today" }
        return "\(names[0]), \(names[1]) +\(pets.count - 2) are safe today"
    }

    var vaccineDueCount: Int {
        events.filter { $0.type == .vaccine && $0.status == .scheduled }.count
    }

    var nextScheduledDate: Date? {
        events
            .filter { $0.status == .scheduled }
            .sorted(by: { $0.scheduledAt < $1.scheduledAt })
            .first?
            .scheduledAt
    }

    var scheduledCareCount: Int {
        events.filter { $0.status == .scheduled }.count
    }

    var completedCareCount: Int {
        events.filter { $0.status == .completed }.count
    }

    var soonestCareEvents: [CareEvent] {
        events
            .filter { $0.status == .scheduled }
            .sorted(by: { $0.scheduledAt < $1.scheduledAt })
            .prefix(3)
            .map { $0 }
    }

    func relativeDaysString(for date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        switch days {
        case ...0: return "today"
        case 1: return "in 1 day"
        default: return "in \(days) days"
        }
    }
}
