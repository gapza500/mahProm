import SwiftUI
import PetReadyShared

struct RiderAuthView: View {
    enum Mode: String, CaseIterable {
        case login = "Login"
        case request = "Request Access"
    }

    @EnvironmentObject private var authService: AuthService
    @State private var mode: Mode = .login
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phone: String = ""
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

            if mode == .request {
                TextField("Full name", text: $name)
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
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

            if mode == .request {
                TextField("Phone (optional)", text: $phone)
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
                        Text(mode == .login ? "Login" : "Submit Request")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")], startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .foregroundStyle(.white)
                .disabled(isSubmitting)
            }
        }
        .padding()
    }

    private func submit() {
        errorMessage = nil
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        if mode == .request && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please tell us your name."
            return
        }

        isSubmitting = true
        Task {
            do {
                switch mode {
                case .login:
                    try await authService.signIn(email: email, password: password)
                case .request:
                    try await authService.signUp(
                        email: email,
                        password: password,
                        displayName: name,
                        role: .rider,
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
}
