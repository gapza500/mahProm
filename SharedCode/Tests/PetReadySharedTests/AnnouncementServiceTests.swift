import XCTest
@testable import PetReadyShared

final class AnnouncementServiceTests: XCTestCase {
    func testClinicFiltering() async {
        let service = AnnouncementService()
        let clinicA = UUID()
        let clinicAnnouncement = GovernmentAnnouncement(title: "Clinic A update", content: "Parking closed", priority: "high", targetAudience: "clinic", clinicId: clinicA)
        await service.createAnnouncement(clinicAnnouncement)

        let all = await service.fetchAnnouncements(clinicId: nil)
        XCTAssertTrue(all.contains(where: { $0.title == "Clinic A update" }))

        let clinicResults = await service.fetchAnnouncements(clinicId: clinicA)
        XCTAssertEqual(clinicResults.first?.clinicId, clinicA)
    }
}
