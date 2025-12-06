import Foundation
import Combine
import SwiftUI
import PhotosUI
import PetReadyShared



@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var text: String = ""
    
    
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    
    private let userId: String = "owner_001"
    private let receiverId: String = "vet_001"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        connect()
    }
    
    // MARK: - Connection
    func connect() {
        WebSocketManager.shared.connect()
    }
    
    func disconnect() {
        WebSocketManager.shared.disconnect()
    }

    // MARK: - Image Logic (Must be here due to PhotosUI)
    func loadSelectedPhoto() {
        guard let selectedPhotoItem = selectedPhotoItem else { return }
        Task {
            if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.selectedImage = image
            }
        }
    }
    
    // MARK: - Sending Logic
    func sendMessage() {
        // 1. Check if sending Image or Text
        guard !text.isEmpty || selectedImage != nil else { return }
        
        let messageText: String
        let messageType: MessageType
        
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            messageText = imageData.base64EncodedString()
            messageType = .image
            self.selectedImage = nil
            self.selectedPhotoItem = nil
        } else {
            messageText = text
            messageType = .text
        }
        
        let message = ChatMessage(
            id: UUID(),
            text: messageText, senderId: userId,
            receiverId: receiverId,
            timestamp: Date(),
            type: messageType
        )
        
        // Update UI optimistically
        self.messages.append(message)
        
        // Fix Argument Order: (text, senderId, receiverId)
        WebSocketManager.shared.sendMessage(
            text: messageText,
            senderId: userId,
            receiverId: receiverId
        )
        
        self.text = ""
    }
    
    // MARK: - Receiving Logic
    private func setupBindings() {
        WebSocketManager.shared.$receivedMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self, let data = data else { return }
                
                // Simple check to infer type: assume long string is an image
                let incomingType: MessageType = data.text.count > 500 && data.text.contains("+") ? .image : .text
                
                let newMessage = ChatMessage(
                    id: UUID(),
                    text: data.text, senderId: data.senderId,
                    receiverId: data.receiverId,
                    timestamp: Date(),
                    type: incomingType
                )
                self.messages.append(newMessage)
            }
            .store(in: &cancellables)
    }
}
