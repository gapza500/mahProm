import SwiftUI

public struct AuthFeedbackBanner: View {
    public enum Status {
        case error
        case info
    }

    private let status: Status
    private let message: String

    public init(status: Status, message: String) {
        self.status = status
        self.message = message
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .imageScale(.medium)
                .symbolVariant(.fill)
                .frame(width: 24, height: 24)
                .foregroundStyle(iconColor)
                .padding(8)
                .background(iconBackground, in: Circle())

            Text(message)
                .font(.footnote)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(status == .error ? "Error" : "Info")
        .accessibilityValue(message)
    }

    private var iconName: String {
        switch status {
        case .error: return "exclamationmark.triangle"
        case .info: return "sparkles"
        }
    }

    private var iconColor: Color {
        switch status {
        case .error: return Color(red: 0.78, green: 0.18, blue: 0.18)
        case .info: return Color(red: 0.16, green: 0.45, blue: 0.37)
        }
    }

    private var iconBackground: Color {
        switch status {
        case .error: return Color(red: 1.0, green: 0.89, blue: 0.90)
        case .info: return Color(red: 0.86, green: 0.96, blue: 0.92)
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .error: return Color(red: 1.0, green: 0.95, blue: 0.96)
        case .info: return Color(red: 0.94, green: 0.98, blue: 0.96)
        }
    }

    private var borderColor: Color {
        switch status {
        case .error: return Color(red: 1.0, green: 0.75, blue: 0.79)
        case .info: return Color(red: 0.78, green: 0.92, blue: 0.86)
        }
    }
}
