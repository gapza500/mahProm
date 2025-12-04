import SwiftUI

public struct FirebaseEmailLoginView: View {
    @EnvironmentObject private var authService: AuthService

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
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
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

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
                .foregroundStyle(.white)
                .disabled(isSubmitting)
            }
        }
        .padding()
    }

    private func authenticate() {
        errorMessage = nil
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Both email and password are required."
            return
        }
        isSubmitting = true
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
