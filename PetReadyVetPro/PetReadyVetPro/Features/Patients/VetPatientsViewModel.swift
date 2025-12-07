import Foundation
import Combine
import PetReadyShared

@MainActor
final class VetPatientsViewModel: ObservableObject {
    @Published private(set) var patients: [Pet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let petService: PetServiceProtocol

    init(petService: PetServiceProtocol = PetService(repository: PetRepositoryFactory.makeRepository())) {
        self.petService = petService
    }

    func loadPatients() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let pets = try await petService.loadPets()
            patients = pets.sorted(by: { $0.updatedAt > $1.updatedAt })
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
