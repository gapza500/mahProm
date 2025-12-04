import SwiftUI
import PetReadyShared

struct OwnerPetsView: View {
    @State private var showScanner = false
    @State private var showManual = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { index in
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Pet Profile",
                                message: "Mock screen showing how full medical history, QR exports and GPS breadcrumbs will live for each pet.",
                                icon: "🐾",
                                highlights: [
                                    "Vaccination + reminders timeline",
                                    "Shareable health card & QR export"
                                ]
                            )
                            .navigationTitle("Fluffy \(index + 1)")
                        } label: {
                            petCard(name: "Fluffy \(index + 1)", type: "Dog", age: "\(index + 1) years old")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
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
                        .foregroundStyle(.white)
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
            NavigationStack { PetScanPlaceholderView() }
        }
        .sheet(isPresented: $showManual) {
            NavigationStack { BarcodeClaimView() }
        }
    }

    private func petCard(name: String, type: String, age: String) -> some View {
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
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "A0D8F1"), in: Capsule())

                    Text(age)
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
}
