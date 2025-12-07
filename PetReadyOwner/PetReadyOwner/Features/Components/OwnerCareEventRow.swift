import SwiftUI
import PetReadyShared

struct OwnerCareEventRow: View {
    let event: CareEvent

    private var statusColor: Color {
        switch event.status {
        case .completed: return Color(hex: "8ED081")
        case .inProgress: return Color(hex: "F7B801")
        case .cancelled: return .gray
        case .scheduled: return Color(hex: "5EA3F7")
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title3)
                .frame(width: 32, height: 32)
                .background(Color.white, in: Circle())
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                    Spacer()
                    Text(event.status.rawValue.capitalized)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor, in: Capsule())
                }

                Text(event.scheduledAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let notes = event.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let outcome = event.outcomeNotes, !outcome.isEmpty {
                    Text(outcome)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var icon: String {
        switch event.type {
        case .vaccine: return "💉"
        case .treatment: return "💊"
        case .checkup: return "🩺"
        case .grooming: return "✂️"
        case .surgery: return "🏥"
        case .lab: return "🧪"
        }
    }
}
