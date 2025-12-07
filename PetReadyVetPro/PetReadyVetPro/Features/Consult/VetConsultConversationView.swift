import SwiftUI
import PetReadyShared

struct VetConsultConversationView: View {
    @StateObject private var viewModel: ConsultConversationViewModel

    init(session: ConsultationSession, profile: UserProfile) {
        _viewModel = StateObject(wrappedValue: ConsultConversationViewModel(session: session, senderProfile: profile, senderRole: .vet))
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            bubble(for: message)
                                .id(message.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack(spacing: 12) {
                TextField("Message", text: $viewModel.draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button(action: { Task { await viewModel.send() } }) {
                    if viewModel.isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
            }
            .padding()
        }
        .navigationTitle(viewModel.session.ownerName ?? "Consultation")
        .background(DesignSystem.Colors.appBackground)
        .alert("Message", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented { viewModel.clearError() }
            }
        )) {
            Button("OK", role: .cancel) { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func bubble(for message: ChatMessage) -> some View {
        let isMe = message.senderId == viewModel.senderProfile.id
        VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
            Text(message.text)
                .padding(10)
                .background(isMe ? Color(hex: "8C6FF7") : Color.white)
                .foregroundStyle(isMe ? Color.white : DesignSystem.Colors.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Text(message.createdAt, style: .time)
                .font(.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
    }
}
