import SwiftUI
import PetReadyShared

struct AdminAuthView: View {
    enum Mode: String, CaseIterable {
        case login = "Login"
        case request = "Request Access"
    }

    @EnvironmentObject private var authService: AuthService
    @State private var mode: Mode = .login
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var reason: String = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false
    @State private var infoMessage: String?
    @State private var showResetConfirmation = false

    var body: some View {
        VStack(spacing: 24) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if mode == .request {
                TextField("Full Name", text: $fullName)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

            if mode == .request {
                TextField("Why do you need access?", text: $reason, axis: .vertical)
                    .lineLimit(2...4)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }

            if let message = errorMessage ?? authService.errorDescription {
                AuthFeedbackBanner(status: .error, message: message)
            }
            if let infoMessage {
                AuthFeedbackBanner(status: .info, message: infoMessage)
            }

            if mode == .login {
                Button("Forgot password?") {
                    guard !email.isEmpty else {
                        errorMessage = "Enter your email first."
                        return
                    }
                    showResetConfirmation = true
                }
                .font(.footnote.weight(.semibold))
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Button(action: submit) {
                HStack {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text(mode == .login ? "Login" : "Send Request")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(hex: "7FD1AE"), Color(hex: "C1F0D7")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .foregroundStyle(.white)
                .disabled(isSubmitting)
            }

            HStack {
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
                Text("OR").font(.caption).foregroundStyle(.secondary)
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            }

            Button(action: signInWithGoogle) {
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
            Button("Send reset", role: .none) {
                Task { await sendReset() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll email reset instructions to \(email).")
        }
    }

    private func submit() {
        errorMessage = nil
        infoMessage = nil
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        if mode == .request && fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please tell us who you are."
            return
        }
        isSubmitting = true
        Task { @MainActor in
            do {
                switch mode {
                case .login:
                    try await authService.signIn(email: email, password: password)
                case .request:
                    try await authService.signUp(
                        email: email,
                        password: password,
                        displayName: fullName,
                        role: .admin,
                        status: .pending,
                        phone: nil
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }

    private func signInWithGoogle() {
        errorMessage = nil
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

    private func sendReset() async {
        guard !email.isEmpty else {
            errorMessage = "Enter your email first."
            return
        }
        isSubmitting = true
        do {
            try await authService.sendPasswordReset(email: email)
            infoMessage = "Password reset email sent."
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}
