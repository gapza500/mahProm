import SwiftUI

public struct RoleGateView<Content: View, LoginView: View, PendingView: View>: View {
    private let allowedRoles: Set<UserType>
    private let content: () -> Content
    private let loginView: () -> LoginView
    private let pendingView: () -> PendingView
    private let refreshInterval: TimeInterval
    @State private var refreshTask: Task<Void, Never>?

    @EnvironmentObject private var authService: AuthService

    public init(
        allowedRoles: [UserType],
        @ViewBuilder loginView: @escaping () -> LoginView = { FirebaseEmailLoginView() },
        @ViewBuilder pendingView: @escaping () -> PendingView = { DefaultPendingApprovalView() },
        refreshInterval: TimeInterval = 10,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.allowedRoles = Set(allowedRoles)
        self.loginView = loginView
        self.pendingView = pendingView
        self.content = content
        self.refreshInterval = refreshInterval
    }

    public var body: some View {
        Group {
            if !authService.isAuthenticated {
                loginView()
            } else if let currentRole = resolvedRole {
                if currentRole == .tester || allowedRoles.contains(currentRole) {
                    if isApproved(for: currentRole) {
                        content()
                    } else {
                        pendingView()
                    }
                } else {
                    UnauthorizedRoleView(role: currentRole, allowedRoles: Array(allowedRoles))
                }
            } else if authService.isProfileLoading {
                ProgressStateView(message: "Checking permissions…")
            } else {
                ProgressStateView(message: "Loading profile…")
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
        .task(id: authService.profile?.status) {
            refreshTask?.cancel()
            guard authService.profile?.status == .pending else { return }
            refreshTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(refreshInterval * 1_000_000_000))
                    if Task.isCancelled { break }
                    await authService.refreshRole()
                }
            }
        }
        .onDisappear {
            refreshTask?.cancel()
        }
    }

    private var resolvedRole: UserType? {
        authService.role ?? authService.profile?.role
    }

    private func isApproved(for role: UserType) -> Bool {
        if role == .tester { return true }
        guard let profile = authService.profile else {
            // legacy users without profile docs fall back to claim
            return authService.role == role
        }
        return profile.status == .approved
    }
}

private struct UnauthorizedRoleView: View {
    let role: UserType
    let allowedRoles: [UserType]

    var body: some View {
        VStack(spacing: 16) {
            Text("🚫")
                .font(.system(size: 56))
            Text("This app is for \(allowedRolesDescription)")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("You're signed in as \(role.rawValue.capitalized). Please switch to the correct PetReady app for your role or contact support.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var allowedRolesDescription: String {
        allowedRoles
            .map { $0.rawValue.capitalized }
            .joined(separator: ", ")
    }
}

public struct DefaultPendingApprovalView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Your account is waiting for approval.")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("We'll notify you once an admin approves your access.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct ProgressStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
