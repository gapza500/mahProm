import SwiftUI

struct OwnerClinicsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        clinicCard(name: "Vet Clinic \(index + 1)", distance: "\(0.5 + Double(index) * 0.3) km")
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Clinics")
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
