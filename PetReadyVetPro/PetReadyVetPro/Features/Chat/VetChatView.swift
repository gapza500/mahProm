import SwiftUI
import PhotosUI
import Combine
import PetReadyShared

// NOTE: VetChatViewModel must be defined in accessible file (VetChatViewModel.swift)

struct VetChatView: View {
    @StateObject private var viewModel = VetChatViewModel()
    @State private var showVideoCall = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Omitted for brevity, but assumed correct)
            HStack {
                Image(systemName: "person.circle.fill").foregroundColor(.green)
                Text("กำลังคุยกับ: คุณเจ้าของ (Owner)").font(.headline).foregroundColor(.green)
                Spacer()
            }.padding().background(Color.green.opacity(0.1))
            
            // Preview Image (Assumed correct)
            if let previewImage = viewModel.selectedImage {
                HStack {
                    Image(uiImage: previewImage).resizable().scaledToFit().frame(height: 80).cornerRadius(8)
                    Button(action: { viewModel.selectedImage = nil; viewModel.selectedPhotoItem = nil }) { Image(systemName: "xmark.circle.fill").foregroundColor(.gray) }
                    Spacer()
                }.padding(.horizontal)
            }
            
            // Chat Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { msg in
                            // ✅ Fix: ใช้ MessageRow ที่จัด Style แล้ว
                            MessageRow(
                                message: msg,
                                isMe: msg.senderId == viewModel.userId // กำหนด isMe จาก ViewModel
                            )
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                    }
                }
            }
            
            // Input Area (Assumed correct)
            HStack(spacing: 10) {
                Button { showVideoCall = true } label: { Image(systemName: "video.fill").font(.title2).foregroundColor(.green) }
                
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) { Image(systemName: "photo").font(.title2).foregroundColor(.green) }
                    .onChange(of: viewModel.selectedPhotoItem) { viewModel.loadSelectedPhoto() }

                TextField("ตอบกลับเจ้าของ...", text: $viewModel.text)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.selectedImage != nil)
                
                Button { viewModel.sendMessage() } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(!viewModel.text.isEmpty || viewModel.selectedImage != nil ? .green : .gray)
                }
                .disabled(viewModel.text.isEmpty && viewModel.selectedImage == nil)
            }
            .padding()
        }
        .navigationTitle("Vet Consult")
        .onAppear(perform: viewModel.connect)
        .onDisappear(perform: viewModel.disconnect)
        .fullScreenCover(isPresented: $showVideoCall) { VideoCallView() }
    }
}

// ----------------------------------------------------
// ✅ STRUCT: MessageRow (ถูกแก้ไขให้มี Bubble Style แล้ว)
// ----------------------------------------------------
fileprivate struct MessageRow: View {
    let message: ChatMessage
    let isMe: Bool
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            
            VStack(alignment: isMe ? .trailing : .leading) {
                // 1. Content (Text or Image)
                Group {
                    if message.type == MessageType.text {
                        Text(message.text)
                    } else if message.type == MessageType.image {
                        if let image = Image(base64String: message.text) {
                            image.resizable().scaledToFit().frame(maxWidth: 200).cornerRadius(12)
                        } else {
                            Text("Invalid Image").italic().foregroundColor(.red)
                        }
                    } else {
                        Text("Unknown Message Type")
                    }
                }
                .padding(10)
                // 2. Bubble Styling
                .background(isMe ? .green.opacity(0.8) : Color(.systemGray5))
                .foregroundColor(isMe ? .white : .primary)
                .cornerRadius(16, corners: isMe ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                .frame(maxWidth: 300, alignment: isMe ? .trailing : .leading)
                
                // 3. Timestamp
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isMe { Spacer() }
        }
    }
}

// Helper Extension สำหรับ Rounded Corners
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Helper Extension สำหรับการแปลง Base64 String กลับเป็น Image
fileprivate extension Image {
    init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        self.init(uiImage: uiImage)
    }
}
