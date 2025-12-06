import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

@MainActor
public protocol AppointmentServiceProtocol {
    func requestAppointment(_ request: AppointmentRequest) async -> Appointment
    func fetchAppointments(ownerId: UUID) async -> [Appointment]
    func fetchClinicAppointments(clinicId: UUID) async -> [Appointment]
    func updateStatus(appointmentId: UUID, status: AppointmentStatus, notes: String?) async -> Appointment?
}

@MainActor
public final class AppointmentService: AppointmentServiceProtocol {
    public static let shared = AppointmentService()

    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    #endif

    private var store: [UUID: Appointment] = [:]

    public init() {}

    public func requestAppointment(_ request: AppointmentRequest) async -> Appointment {
        var appointment = Appointment(
            ownerId: request.ownerId,
            petId: request.petId,
            clinicId: request.clinicId,
            date: request.requestedDate,
            status: .pending,
            reason: request.reason,
            notes: request.notes
        )
        store[appointment.id] = appointment
#if canImport(FirebaseFirestore)
        do {
            let data = try JSONSerialization.jsonObject(with: encoder.encode(appointment)) as? [String: Any] ?? [:]
            try await db.collection("appointments").document(appointment.id.uuidString).setData(data)
        } catch {
            // fall back to in-memory only
        }
#endif
        return appointment
    }

    public func fetchAppointments(ownerId: UUID) async -> [Appointment] {
#if canImport(FirebaseFirestore)
        do {
            let snapshot = try await db.collection("appointments").whereField("ownerId", isEqualTo: ownerId.uuidString).getDocuments()
            let remote: [Appointment] = snapshot.documents.compactMap { doc in
                guard let data = try? JSONSerialization.data(withJSONObject: doc.data()) else { return nil }
                return try? decoder.decode(Appointment.self, from: data)
            }
            if !remote.isEmpty { return remote.sorted { $0.date < $1.date } }
        } catch {
            // ignore and return cached
        }
#endif
        return store.values.filter { $0.ownerId == ownerId }.sorted { $0.date < $1.date }
    }

    public func fetchClinicAppointments(clinicId: UUID) async -> [Appointment] {
#if canImport(FirebaseFirestore)
        do {
            let snapshot = try await db.collection("appointments").whereField("clinicId", isEqualTo: clinicId.uuidString).getDocuments()
            let remote: [Appointment] = snapshot.documents.compactMap { doc in
                guard let data = try? JSONSerialization.data(withJSONObject: doc.data()) else { return nil }
                return try? decoder.decode(Appointment.self, from: data)
            }
            if !remote.isEmpty { return remote.sorted { $0.date < $1.date } }
        } catch {
            // ignore and return cached
        }
#endif
        return store.values.filter { $0.clinicId == clinicId }.sorted { $0.date < $1.date }
    }

    public func updateStatus(appointmentId: UUID, status: AppointmentStatus, notes: String?) async -> Appointment? {
        guard var appointment = store[appointmentId] else {
#if canImport(FirebaseFirestore)
            do {
                let doc = try await db.collection("appointments").document(appointmentId.uuidString).getDocument()
                let data = doc.data()
                if let json = try? JSONSerialization.data(withJSONObject: data), var decoded = try? decoder.decode(Appointment.self, from: json) {
                    decoded.status = status
                    decoded.notes = notes
                    decoded.updatedAt = Date()
                    store[decoded.id] = decoded
                    try await db.collection("appointments").document(decoded.id.uuidString).updateData([
                        "status": status.rawValue,
                        "notes": notes as Any,
                        "updatedAt": Date()
                    ])
                    return decoded
                }
            } catch {
                return nil
            }
#endif
            return nil
        }

        appointment.status = status
        appointment.notes = notes
        appointment.updatedAt = Date()
        store[appointment.id] = appointment
#if canImport(FirebaseFirestore)
        try? await db.collection("appointments").document(appointment.id.uuidString).updateData([
            "status": status.rawValue,
            "notes": notes as Any,
            "updatedAt": Date()
        ])
#endif
        return appointment
    }
}
