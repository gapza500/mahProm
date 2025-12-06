import XCTest
@testable import PetReadyShared

final class HealthRecordServiceTests: XCTestCase {
    func testSeedAndAddVaccine() async {
        let service = HealthRecordService()
        let petId = UUID()

        var vaccines = await service.fetchVaccines(petId: petId)
        XCTAssertFalse(vaccines.isEmpty)

        let extra = VaccineRecord(petId: petId, vaccineType: "Leptospirosis")
        await service.addVaccine(extra)

        vaccines = await service.fetchVaccines(petId: petId)
        XCTAssertTrue(vaccines.contains(where: { $0.vaccineType == "Leptospirosis" }))
    }

    func testTreatmentsOrdering() async {
        let service = HealthRecordService()
        let petId = UUID()
        _ = await service.fetchTreatments(petId: petId)

        let now = Date()
        let older = TreatmentRecord(petId: petId, title: "Older Visit", detail: "Notes", performedAt: now.addingTimeInterval(-10_000))
        await service.addTreatment(older)

        let treatments = await service.fetchTreatments(petId: petId)
        let sorted = treatments.sorted { $0.performedAt > $1.performedAt }
        XCTAssertEqual(treatments.map(\.id), sorted.map(\.id))
    }
}
