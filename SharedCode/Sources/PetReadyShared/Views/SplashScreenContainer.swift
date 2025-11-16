import SwiftUI

public struct SplashScreenContainer<Content: View>: View {
    private let appName: String
    private let accentColor: Color
    private let content: () -> Content
    @State private var isActive = false

    public init(appName: String, accentColor: Color = .blue, @ViewBuilder content: @escaping () -> Content) {
        self.appName = appName
        self.accentColor = accentColor
        self.content = content
    }

    public var body: some View {
        ZStack {
            content()
                .opacity(isActive ? 1 : 0)
            if !isActive {
                SplashScreenView(appName: appName, accentColor: accentColor)
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeOut(duration: 0.4)) {
                isActive = true
            }
        }
    }
}

private struct SplashScreenView: View {
    let appName: String
    let accentColor: Color
    @State private var pulse = false

    var body: some View {
        LinearGradient(
            colors: [
                accentColor.opacity(0.85),
                accentColor.opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 160, height: 160)
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 6)
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulse ? 1.05 : 0.95)
                        .opacity(0.8)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.white)
                }

                Text(appName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.2)
            }
        )
        .onAppear { pulse = true }
    }
}
