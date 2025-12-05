import XCTest
@testable import PetReadyShared

final class SOSServiceTests: XCTestCase {
    func testCreateAndAssignSOSCase() async throws {
        let service = SOSService()
        let request = SOSRequest(
            requesterId: UUID(),
            petId: nil,
            incidentType: .injury,
            priority: .critical,
            pickup: Coordinate(latitude: 13.75, longitude: 100.50)
        )

        let created = try await service.createCase(request)
        XCTAssertEqual(created.status, .pending)
        XCTAssertEqual(created.incidentType, .injury)

        let riderId = UUID()
        let assigned = try await service.acceptCase(id: created.id, riderId: riderId)
        XCTAssertEqual(assigned.riderId, riderId)
        XCTAssertEqual(assigned.status, .assigned)
    }

    func testObserverReceivesUpdates() async throws {
        let service = SOSService()
        let expect = expectation(description: "observer")

        service.observeCases { cases in
            if cases.count == 1 {
                expect.fulfill()
            }
        }

        _ = try await service.createCase(
            SOSRequest(
                requesterId: UUID(),
                petId: nil,
                incidentType: .transport,
                priority: .urgent,
                pickup: Coordinate(latitude: 13.75, longitude: 100.50)
            )
        )

        wait(for: [expect], timeout: 1.0)
    }

    func testBeaconUpdatesLocation() async throws {
        let service = SOSService()
        let created = try await service.createCase(
            SOSRequest(
                requesterId: UUID(),
                petId: nil,
                incidentType: .other,
                priority: .routine,
                pickup: Coordinate(latitude: 13.0, longitude: 100.0)
            )
        )

        let beacon = Coordinate(latitude: 14.1, longitude: 101.2)
        await service.recordBeacon(id: created.id, coordinate: beacon, note: "En route")
        let cases = await service.fetchCases()
        let updated = cases.first(where: { $0.id == created.id })
        XCTAssertEqual(updated?.lastKnownLocation?.latitude, beacon.latitude)
        XCTAssertEqual(updated?.lastKnownLocation?.longitude, beacon.longitude)
    }
}
