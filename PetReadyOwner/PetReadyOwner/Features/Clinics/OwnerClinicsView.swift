import SwiftUI
import PetReadyShared

struct OwnerClinicsView: View {
    @State private var isShowingFilters = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Clinic Profile",
                                message: "Full detail page for partners with slots, documents, pricing and SOS escalation toggles.",
                                icon: "🏥",
                                highlights: [
                                    "Availability synced with queue monitor",
                                    "Carousel for promotions + documents"
                                ]
                            )
                            .navigationTitle("Vet Clinic \(index + 1)")
                        } label: {
                            clinicCard(name: "Vet Clinic \(index + 1)", distance: "\(0.5 + Double(index) * 0.3) km")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Clinics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingFilters = true
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingFilters) {
            OwnerClinicFilterView()
        }
    }

    private func clinicCard(name: String, distance: String) -> some View {
        HStack(spacing: 16) {
            Text("🏥")
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "98D8AA").opacity(0.2), Color(hex: "C8EED4").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.body.weight(.semibold))

                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text(distance)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                Text("Map • Promotions • Booking")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white)

                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "E8FFE8").opacity(0.5), Color(hex: "FFFFFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(hex: "98D8AA").opacity(0.2), lineWidth: 2)
        )
        .shadow(color: Color(hex: "98D8AA").opacity(0.15), radius: 10, y: 6)
    }
}

struct OwnerClinicFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var maxDistance: Double = 5
    @State private var showEmergency = true
    @State private var showAfterHours = false
    @State private var onlyPartners = true

    private let route = LocationService().requestMockRoute()

    var body: some View {
        NavigationStack {
            Form {
                Section("Distance") {
                    VStack(alignment: .leading) {
                        Slider(value: $maxDistance, in: 1...15, step: 1)
                        Text("Within \(Int(maxDistance)) km")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Services") {
                    Toggle("Emergency ready", isOn: $showEmergency)
                    Toggle("After-hours support", isOn: $showAfterHours)
                    Toggle("PetReady partners only", isOn: $onlyPartners)
                }

                Section("Live GPS preview") {
                    ForEach(route) { stop in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stop.title)
                                .font(.subheadline.weight(.semibold))
                            Text(stop.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("Route powered by the shared LocationService stub.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Clinic Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { dismiss() }
                }
            }
        }
    }
}
