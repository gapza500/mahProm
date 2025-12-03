import PetReadyShared

final class AdminDependencies {
    static let shared = AdminDependencies()
    let petListViewModel: PetListViewModel

    private init() {
        let repository = PetRepositoryFactory.makeRepository()
        let service = PetService(repository: repository)
        petListViewModel = PetListViewModel(service: service)
    }
}
