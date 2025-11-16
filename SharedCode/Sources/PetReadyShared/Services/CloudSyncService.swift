import CloudKit

public final class CloudSyncService {
    private let container: CKContainer
    private let privateDB: CKDatabase

    public init(containerIdentifier: String) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.privateDB = container.privateCloudDatabase
    }

    public func save(record: CKRecord) async throws {
        _ = try await privateDB.save(record)
    }

    public func fetch(recordType: String, predicate: NSPredicate = NSPredicate(value: true)) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        var records: [CKRecord] = []
        let (matchResults, _) = try await privateDB.records(matching: query)
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                throw error
            }
        }
        return records
    }
}
