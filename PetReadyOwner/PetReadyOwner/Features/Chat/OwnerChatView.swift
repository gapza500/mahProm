import SwiftUI
import PhotosUI
import PetReadyShared

struct OwnerChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showVideoCall = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { msg in
                            HStack(alignment: .bottom) {
                                if msg.isMe { Spacer() }
                                
                                VStack(alignment: msg.isMe ? .trailing : .leading) {
                                    if msg.type == .text {
                                        Text(msg.text).padding().background(msg.isMe ? Color.blue : Color.gray.opacity(0.2)).cornerRadius(12)
                                    } else if msg.type == .image {
                                        HStack { Text("Image Sent"); Image(systemName: "photo") }
                                    }
                                }
                                
                                if !msg.isMe { Spacer() }
                            }
                            .id(msg.id)
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
            
            HStack(spacing: 10) {
                Button { showVideoCall = true } label: { Image(systemName: "video.fill").font(.title2).foregroundColor(.blue) }
                
                TextField("พิมพ์ข้อความ...", text: $viewModel.text).textFieldStyle(.roundedBorder)
                
                Button { viewModel.sendMessage() } label: { Image(systemName: "paperplane.fill").font(.title2).foregroundColor(.blue) }
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear { viewModel.connect() }
        .fullScreenCover(isPresented: $showVideoCall) { VideoCallView() }
    }
}
