import XCTest
@testable import PetReadyShared

final class SmartVetCommunicationServiceTests: XCTestCase {
    func testRequestConsultationAndMessages() async {
        let service = SmartVetCommunicationService()
        let vets = await service.listAvailableVets()
        let vet = vets.first!
        let owner = UUID()

        let session = await service.requestConsultation(vet: vet, ownerId: owner, petName: "Mochi")
        XCTAssertEqual(session.vet.id, vet.id)

        let sessions = await service.sessions(forOwner: owner)
        XCTAssertEqual(sessions.count, 1)

        let _ = await service.sendOwnerMessage("Hello doctor", in: session, ownerId: owner)
        let messages = service.messages(for: session.conversationId)
        XCTAssertTrue(messages.contains(where: { $0.text.contains("Hello doctor") }))
    }
}
