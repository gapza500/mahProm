import CoreData

public final class CoreDataStack {
    public static let shared = CoreDataStack()

    public let persistentContainer: NSPersistentContainer

    private init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "PetReady")
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("CoreData failed to load: \(error)")
            }
        }
    }

    public func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            assertionFailure("Failed to save context: \(error)")
        }
    }
}
