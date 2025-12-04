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
        Task {
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
}
