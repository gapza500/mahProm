import Foundation

public final class PetListViewModel: ObservableObject {
    @Published public private(set) var pets: [Pet] = []
    private let service: PetServiceProtocol

    public init(service: PetServiceProtocol) {
        self.service = service
    }

    @MainActor
    public func loadPets() async {
        do {
            pets = try await service.loadPets()
        } catch {
            print("Failed to load pets: \(error)")
        }
    }
}
