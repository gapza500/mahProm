import SwiftUI
import PetReadyShared

struct ClinicAppointmentsView: View {
    @StateObject private var viewModel = ClinicAppointmentsViewModel()

    var body: some View {
        List {
            Section("Pending") {
                if viewModel.pendingAppointments.isEmpty {
                    Text("No pending requests.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.pendingAppointments) { appointment in
                        ClinicAppointmentRow(
                            appointment: appointment,
                            approve: { Task { await viewModel.update(appointment, status: .approved) } },
                            decline: { Task { await viewModel.update(appointment, status: .declined) } }
                        )
                    }
                }
            }
            Section("Upcoming") {
                ForEach(viewModel.upcomingApproved) { appointment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.reason ?? "Appointment")
                            .font(.headline)
                        Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Clinic Appointments")
        .task { await viewModel.load() }
    }
}

struct ClinicAppointmentRow: View {
    let appointment: Appointment
    let approve: () -> Void
    let decline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(appointment.reason ?? "Appointment")
                .font(.headline)
            Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Button("Approve", action: approve)
                    .buttonStyle(.borderedProminent)
                Button("Decline", action: decline)
                    .buttonStyle(.bordered)
            }
        }
    }
}

@MainActor
final class ClinicAppointmentsViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []

    private let appointmentService: AppointmentServiceProtocol
    private let clinicIdentity: ClinicIdentityStore

    init(
        appointmentService: AppointmentServiceProtocol = AppointmentService.shared,
        clinicIdentity: ClinicIdentityStore = .shared
    ) {
        self.appointmentService = appointmentService
        self.clinicIdentity = clinicIdentity
    }

    var pendingAppointments: [Appointment] {
        appointments.filter { $0.status == .pending }
    }

    var upcomingApproved: [Appointment] {
        appointments.filter { $0.status == .approved && $0.date >= Date() }
    }

    func load() async {
        appointments = await appointmentService.fetchClinicAppointments(clinicId: clinicIdentity.clinicId)
    }

    func update(_ appointment: Appointment, status: AppointmentStatus) async {
        guard let updated = await appointmentService.updateStatus(appointmentId: appointment.id, status: status, notes: nil) else { return }
        if let index = appointments.firstIndex(where: { $0.id == updated.id }) {
            appointments[index] = updated
        }
    }
}
