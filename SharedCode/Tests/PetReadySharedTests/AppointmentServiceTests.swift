import XCTest
@testable import PetReadyShared

final class AppointmentServiceTests: XCTestCase {
    func testStubAppointmentLifecycle() async throws {
        let stub = InMemoryAppointmentService()
        let ownerId = UUID()
        let clinicId = UUID()
        let requestedDate = Date().addingTimeInterval(3_600)

        let created = await stub.requestAppointment(AppointmentRequest(ownerId: ownerId, petId: nil, clinicId: clinicId, requestedDate: requestedDate, reason: "Check-up"))
        XCTAssertEqual(created.status, .pending)
        XCTAssertEqual(created.clinicId, clinicId)

        let ownerAppointments = await stub.fetchAppointments(ownerId: ownerId)
        XCTAssertEqual(ownerAppointments.count, 1)

        _ = await stub.updateStatus(appointmentId: created.id, status: .approved, notes: nil)
        let clinicAppointments = await stub.fetchClinicAppointments(clinicId: clinicId)
        XCTAssertEqual(clinicAppointments.first?.status, .approved)
    }
}

/// Lightweight in-memory test double to validate protocol behaviour without hitting Firestore.
final class InMemoryAppointmentService: AppointmentServiceProtocol {
    private var store: [UUID: Appointment] = [:]

    func requestAppointment(_ request: AppointmentRequest) async -> Appointment {
        let appointment = Appointment(ownerId: request.ownerId, petId: request.petId, clinicId: request.clinicId, date: request.requestedDate, status: .pending, reason: request.reason, notes: request.notes)
        store[appointment.id] = appointment
        return appointment
    }

    func fetchAppointments(ownerId: UUID) async -> [Appointment] {
        store.values.filter { $0.ownerId == ownerId }
    }

    func fetchClinicAppointments(clinicId: UUID) async -> [Appointment] {
        store.values.filter { $0.clinicId == clinicId }
    }

    func updateStatus(appointmentId: UUID, status: AppointmentStatus, notes: String?) async -> Appointment? {
        guard var appointment = store[appointmentId] else { return nil }
        appointment.status = status
        appointment.notes = notes
        appointment.updatedAt = Date()
        store[appointmentId] = appointment
        return appointment
    }
}
