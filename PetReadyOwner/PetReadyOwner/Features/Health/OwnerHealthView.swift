import SwiftUI
import PetReadyShared

struct OwnerHealthView: View {
    @StateObject private var viewModel = OwnerHealthViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if let pet = viewModel.selectedPet {
                        petHeader(for: pet)
                        upcomingVaccinesSection
                        treatmentsSection
                        appointmentsSection
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Health")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let pet = viewModel.selectedPet {
                        NavigationLink {
                            HealthQRView(pet: pet)
                        } label: {
                            Label("Health QR", systemImage: "qrcode")
                        }
                    }
                }
            }
        }
        .task { await viewModel.load() }
    }

    private func petHeader(for pet: Pet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pet.name)
                    .font(.title2.bold())
                Spacer()
                if viewModel.pets.count > 1 {
                    Menu {
                        ForEach(viewModel.pets) { candidate in
                            Button(candidate.name) { viewModel.selectPet(candidate) }
                        }
                    } label: {
                        Label("Switch", systemImage: "arrow.2.circlepath")
                            .font(.caption.weight(.semibold))
                    }
                }
            }
            Text(pet.species.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var upcomingVaccinesSection: some View {
        cuteCard("Upcoming Vaccines", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
            if viewModel.upcomingVaccines.isEmpty {
                Text("No upcoming vaccines.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.upcomingVaccines) { record in
                    cuteInfoRow(
                        icon: "💉",
                        title: record.vaccineType,
                        subtitle: "Next due \(record.nextDue?.formatted(date: .abbreviated, time: .omitted) ?? record.date.formatted(date: .abbreviated, time: .omitted))",
                        badge: "Soon",
                        badgeColor: Color(hex: "FFE5A0")
                    )
                    if record.id != viewModel.upcomingVaccines.last?.id {
                        Divider().padding(.leading, 50)
                    }
                }
            }
        }
    }

    private var treatmentsSection: some View {
        cuteCard("Treatment Timeline", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            if viewModel.recentTreatments.isEmpty {
                Text("No treatments recorded yet.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentTreatments) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.title)
                            .font(.subheadline.weight(.semibold))
                        Text(record.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(record.performedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if record.id != viewModel.recentTreatments.last?.id {
                        Divider().padding(.leading, 8)
                    }
                }
            }
        }
    }

    private var appointmentsSection: some View {
        cuteCard("Upcoming Appointments", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
            if viewModel.upcomingAppointments.isEmpty {
                Text("No bookings yet. Visit Clinics tab to schedule.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.upcomingAppointments) { appointment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.reason ?? "Clinic appointment")
                            .font(.subheadline.weight(.semibold))
                        Text("Date: \(appointment.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Status: \(appointment.status.readableLabel)")
                            .font(.caption2)
                            .foregroundStyle(statusColor(for: appointment.status))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if appointment.id != viewModel.upcomingAppointments.last?.id {
                        Divider().padding(.leading, 8)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("No pets yet")
                .font(.title3.bold())
            Text("Register your pet via barcode to see health updates.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
        )
    }

    private func statusColor(for status: AppointmentStatus) -> Color {
        switch status {
        case .approved: return Color(hex: "98D8AA")
        case .declined, .cancelled: return .red
        case .completed: return Color(hex: "A0D8F1")
        case .pending: return Color(hex: "FFE5A0")
        }
    }
}

@MainActor
final class OwnerHealthViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var selectedPet: Pet?
    @Published var upcomingVaccines: [VaccineRecord] = []
    @Published var recentTreatments: [TreatmentRecord] = []
    @Published var appointments: [Appointment] = []

    private let petService: PetServiceProtocol
    private let healthService: HealthRecordServiceProtocol
    private let appointmentService: AppointmentServiceProtocol
    private let identityStore: OwnerIdentityStore

    init(
        petService: PetServiceProtocol = PetService(repository: PetRepositoryFactory.makeRepository()),
        healthService: HealthRecordServiceProtocol = HealthRecordService.shared,
        appointmentService: AppointmentServiceProtocol = AppointmentService.shared,
        identityStore: OwnerIdentityStore = .shared
    ) {
        self.petService = petService
        self.healthService = healthService
        self.appointmentService = appointmentService
        self.identityStore = identityStore
    }

    var upcomingAppointments: [Appointment] {
        appointments.filter { $0.date >= Date() }.sorted { $0.date < $1.date }
    }

    func load() async {
        do {
            let loadedPets = try await petService.loadPets()
            await MainActor.run {
                self.pets = loadedPets
                if self.selectedPet == nil {
                    self.selectedPet = loadedPets.first
                }
            }
        } catch {
            print("Failed to load pets: \(error)")
        }

        if let selected = selectedPet ?? pets.first {
            await refreshRecords(for: selected)
        }
        await reloadAppointments()
    }

    func selectPet(_ pet: Pet) {
        selectedPet = pet
        Task { await refreshRecords(for: pet) }
    }

    func reloadAppointments() async {
        let items = await appointmentService.fetchAppointments(ownerId: identityStore.ownerId)
        await MainActor.run { self.appointments = items }
    }

    private func refreshRecords(for pet: Pet) async {
        let vaccines = await healthService.fetchVaccines(petId: pet.id)
        let treatments = await healthService.fetchTreatments(petId: pet.id)
        await MainActor.run {
            self.upcomingVaccines = vaccines
            self.recentTreatments = treatments
        }
    }
}

private extension AppointmentStatus {
    var readableLabel: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .declined: return "Declined"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}
