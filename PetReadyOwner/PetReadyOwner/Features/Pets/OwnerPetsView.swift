import SwiftUI
import PetReadyShared

struct OwnerPetsView: View {
    @State private var showScanner = false
    @State private var showManual = false
    @ObservedObject private var identityStore = OwnerIdentityStore.shared
    @StateObject private var viewModel = PetListViewModel(service: PetService(repository: PetRepositoryFactory.makeRepository()))

    private var ownedPets: [Pet] {
        viewModel.pets.filter { $0.ownerId == identityStore.ownerId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if ownedPets.isEmpty {
                        emptyState
                    } else {
                        ForEach(ownedPets) { pet in
                            NavigationLink {
                                FeaturePlaceholderView(
                                    title: pet.name,
                                    message: "Pet detail will surface timeline, reminders and QR exports.",
                                    icon: "🐾",
                                    highlights: [
                                        "Species: \(pet.species.rawValue.capitalized)",
                                        "Status: \(formattedStatus(pet.status))"
                                    ]
                                )
                                .navigationTitle(pet.name)
                            } label: {
                                petCard(name: pet.name, type: pet.species.rawValue.capitalized, status: formattedStatus(pet.status))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .refreshable { await viewModel.loadPets() }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("My Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Scan Barcode") { showScanner = true }
                        Button("Enter Code Manually") { showManual = true }
                        Button("Add Without Code") {}
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 8, y: 4)
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            NavigationStack {
                PetScanPlaceholderView(onPetClaimed: { _ in
                    showScanner = false
                    Task { await viewModel.loadPets() }
                })
            }
        }
        .sheet(isPresented: $showManual) {
            NavigationStack {
                BarcodeClaimView { _ in
                    showManual = false
                    Task { await viewModel.loadPets() }
                }
            }
        }
        .task { await viewModel.loadPets() }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("No pets yet")
                .font(.title3.bold())
            Text("Ask Central Admin for your barcode, then scan or enter it here to link your pet.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
        )
    }

    private func petCard(name: String, type: String, status: String) -> some View {
        HStack(spacing: 16) {
            Text(type == "Dog" ? "🐶" : "🐱")
                .font(.system(size: 44))
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFB5D8").opacity(0.2), Color(hex: "FFD4E8").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.title3.bold())

                HStack(spacing: 8) {
                    Text(type)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "A0D8F1"), in: Capsule())

                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)

                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFF0F5"), Color(hex: "FFFFFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "FFB5D8").opacity(0.2), lineWidth: 2)
        )
        .shadow(color: Color(hex: "FFB5D8").opacity(0.15), radius: 12, y: 6)
    }

    private func formattedStatus(_ status: String) -> String {
        status.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
