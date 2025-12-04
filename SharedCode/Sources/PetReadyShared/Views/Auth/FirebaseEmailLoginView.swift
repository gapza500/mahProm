import SwiftUI

public struct FirebaseEmailLoginView: View {
    @EnvironmentObject private var authService: AuthService

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?
    @State private var showResetConfirmation = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Welcome to PetReady")
                    .font(.title2.bold())
                Text("Sign in with your tester or team account to continue.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    .focused($focusedField, equals: .email)

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    .focused($focusedField, equals: .password)
            }

            if let errorMessage {
                AuthFeedbackBanner(status: .error, message: errorMessage)
            }
            if let infoMessage {
                AuthFeedbackBanner(status: .info, message: infoMessage)
            }

            Button("Forgot password?") {
                guard !email.isEmpty else {
                    errorMessage = "Enter your email to reset your password."
                    return
                }
                showResetConfirmation = true
            }
            .font(.footnote.weight(.semibold))
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Button(action: authenticate) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.62, blue: 0.80), Color(red: 1.0, green: 0.73, blue: 0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .foregroundStyle(DesignSystem.Colors.onAccentText)
                .disabled(isSubmitting)
            }

            HStack {
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
                Text("OR").font(.caption).foregroundStyle(.secondary)
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            }
            .padding(.vertical, 4)

            Button(action: authenticateWithGoogle) {
                HStack(spacing: 8) {
                    Image(systemName: "globe")
                    Text("Continue with Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(isSubmitting)
        }
        .padding()
        .alert("Send password reset?", isPresented: $showResetConfirmation) {
            Button("Send reset", role: .none) { resetPassword() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll email password reset instructions to \(email).")
        }
    }

    private func authenticate() {
        errorMessage = nil
        infoMessage = nil
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Both email and password are required."
            return
        }
        isSubmitting = true
        Task { @MainActor in
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }

    private func authenticateWithGoogle() {
        errorMessage = nil
        infoMessage = nil
        isSubmitting = true
        Task { @MainActor in
            do {
                try await authService.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }

    private func resetPassword() {
        errorMessage = nil
        infoMessage = nil
        guard !email.isEmpty else {
            errorMessage = "Enter your email to reset your password."
            return
        }
        isSubmitting = true
        Task { @MainActor in
            do {
                try await authService.sendPasswordReset(email: email)
                infoMessage = "Password reset email sent to \(email)."
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
