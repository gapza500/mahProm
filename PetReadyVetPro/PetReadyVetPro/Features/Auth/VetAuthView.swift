import SwiftUI
import PetReadyShared

struct VetAuthView: View {
    enum Mode: String, CaseIterable {
        case login = "Login"
        case apply = "Apply"
    }

    @EnvironmentObject private var authService: AuthService
    @State private var mode: Mode = .login
    @State private var clinicName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phone: String = ""
    @State private var selectedRole: UserType = .vet
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 20) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if mode == .apply {
                TextField("Clinic / Vet Name", text: $clinicName)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                Picker("Applying as", selection: $selectedRole) {
                    Text("Vet").tag(UserType.vet)
                    Text("Clinic").tag(UserType.clinic)
                }
                .pickerStyle(.segmented)
            }

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

            if mode == .apply {
                TextField("Contact phone", text: $phone)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }

            if let message = errorMessage ?? authService.errorDescription {
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
                        Text(mode == .login ? "Login" : "Submit Application")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")], startPoint: .leading, endPoint: .trailing),
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
        errorMessage = nil
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        if mode == .apply && clinicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your clinic or personal name."
            return
        }

        isSubmitting = true
        Task { @MainActor in
            do {
                switch mode {
                case .login:
                    try await authService.signIn(email: email, password: password)
                case .apply:
                    try await authService.signUp(
                        email: email,
                        password: password,
                        displayName: clinicName,
                        role: selectedRole,
                        status: .pending,
                        phone: phone.isEmpty ? nil : phone
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
}
