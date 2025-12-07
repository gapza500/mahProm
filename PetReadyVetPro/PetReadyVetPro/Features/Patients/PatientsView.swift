import SwiftUI
import PetReadyShared

struct PatientsView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = VetPatientsViewModel()

    private var vetProfile: UserProfile? { authService.profile }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.patients.isEmpty {
                    ProgressView("Loading pets…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.patients.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        Text("No pets available yet")
                            .font(.headline)
                        Text("Once owners register, their pets appear here for care planning.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.patients) { pet in
                            NavigationLink {
                                VetPatientDetailView(pet: pet, vetProfile: vetProfile)
                            } label: {
                                patientRow(pet)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Patients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.loadPatients() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task { await viewModel.loadPatients() }
            .refreshable { await viewModel.loadPatients() }
            .alert("Patients", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { newValue in
                    if !newValue { viewModel.errorMessage = nil }
                }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .background(DesignSystem.Colors.appBackground)
        }
    }

    private func patientRow(_ pet: Pet) -> some View {
        HStack(spacing: 16) {
            Text(pet.species == .cat ? "🐱" : (pet.species == .dog ? "🐶" : "🐾"))
                .font(.largeTitle)
                .frame(width: 44, height: 44)
                .background(Color(hex: "F6F0FF"), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.headline)
                Text(ownerLine(for: pet))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(pet.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "E8F4FF"), in: Capsule())
                if let updated = relativeDateString(for: pet.updatedAt) {
                    Text(updated)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func ownerLine(for pet: Pet) -> String {
        if let ownerId = pet.ownerId {
            return "Owner: \(ownerId.uuidString.prefix(6))…"
        } else {
            return "Unclaimed"
        }
    }

    private func relativeDateString(for date: Date) -> String? {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
