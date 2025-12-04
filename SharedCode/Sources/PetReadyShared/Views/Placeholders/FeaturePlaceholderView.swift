import SwiftUI

public struct FeaturePlaceholderView: View {
    public let title: String
    public let message: String
    public let icon: String
    public let highlights: [String]

    public init(title: String, message: String, icon: String = "✨", highlights: [String] = []) {
        self.title = title
        self.message = message
        self.icon = icon
        self.highlights = highlights
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(icon)
                    .font(.system(size: 64))
                    .padding()
                    .background(Color(.systemBackground), in: Circle())
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)

                VStack(spacing: 12) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                if !highlights.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(highlights, id: \.self) { highlight in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Color(red: 0.97, green: 0.44, blue: 0.64))
                                    .font(.body)
                                Text(highlight)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                    }
                    .padding()
                }

                VStack(spacing: 8) {
                    Text("Coming in Phase 2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("We’re locking down the architecture now so the feature can plug right in later.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
