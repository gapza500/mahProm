import SwiftUI
import PetReadyShared

struct OwnerAuthView: View {
    enum Mode: String, CaseIterable {
        case login = "Login"
        case signup = "Sign Up"
    }

    @EnvironmentObject private var authService: AuthService

    @State private var mode: Mode = .login
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSubmitting = false
    @State private var localError: String?

    var body: some View {
        VStack(spacing: 24) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if mode == .signup {
                TextField("Full Name", text: $displayName)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                if mode == .signup {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
            }

            if let message = localError ?? authService.errorDescription {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: submit) {
                HStack {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text(mode == .login ? "Login" : "Create Account")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")],
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
    }

    private func submit() {
        localError = nil
        guard !email.isEmpty, !password.isEmpty else {
            localError = "Please fill in all required fields."
            return
        }

        if mode == .signup {
            guard !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                localError = "Please enter your name."
                return
            }
            guard password == confirmPassword else {
                localError = "Passwords do not match."
                return
            }
        }

        isSubmitting = true
        Task { @MainActor in
            do {
                switch mode {
                case .login:
                    try await authService.signIn(email: email, password: password)
                case .signup:
                    try await authService.signUp(
                        email: email,
                        password: password,
                        displayName: displayName,
                        role: .owner,
                        status: .approved,
                        phone: nil
                    )
                }
            } catch {
                localError = error.localizedDescription
            }
            isSubmitting = false
        }
    }

    private func signInWithGoogle() {
        localError = nil
        isSubmitting = true
        Task { @MainActor in
            do {
                try await authService.signInWithGoogle()
            } catch {
                localError = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
