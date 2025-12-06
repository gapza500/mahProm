import Foundation
import Combine
import PetReadyShared
import SwiftUI
import PhotosUI

// NOTE: ChatMessage and MessageType must be defined in PetReadyShared

class VetChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var text: String = ""
    
    // Image Handling
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    
    // ✅ FIX: ลบ 'private' ออกเพื่อให้ View อ่านค่าไปใช้ได้
    let userId: String = "vet_001"
    private let targetOwnerId: String = "owner_001"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        connect()
    }
    
    func connect() {
        WebSocketManager.shared.connect()
    }
    
    func disconnect() {
        WebSocketManager.shared.disconnect()
    }

    func loadSelectedPhoto() {
        guard let selectedPhotoItem = selectedPhotoItem else { return }
        Task {
            if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run { self.selectedImage = image }
            }
        }
    }
    
    func sendMessage() {
        guard !text.isEmpty || selectedImage != nil else { return }
        
        let messageText: String
        let messageType: MessageType
        
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            messageText = imageData.base64EncodedString()
            messageType = .image
        } else {
            messageText = text
            messageType = .text
        }
        
        let msg = ChatMessage(id: UUID(), text: messageText, senderId: userId, receiverId: targetOwnerId, timestamp: Date(), type: messageType)
        
        self.messages.append(msg)
        
        WebSocketManager.shared.sendMessage(text: messageText, senderId: userId, receiverId: targetOwnerId)
        
        self.text = ""
        self.selectedImage = nil
        self.selectedPhotoItem = nil
    }
    
    private func setupBindings() {
        WebSocketManager.shared.$receivedMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                
                let incomingType: MessageType = data.text.count > 500 && data.text.contains("+") ? .image : .text
                
                let newMessage = ChatMessage(
                    id: UUID(), text: data.text, senderId: data.senderId, receiverId: data.receiverId,
                    timestamp: Date(), type: incomingType
                )
                self.messages.append(newMessage)
            }
            .store(in: &cancellables)
    }
}
