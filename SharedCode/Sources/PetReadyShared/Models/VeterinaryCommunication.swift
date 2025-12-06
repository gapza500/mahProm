import Foundation

public struct VetAvailability: Identifiable, Codable, Sendable, Equatable {
    public enum Status: String, Codable, Sendable {
        case available, busy, offline
    }

    public let id: UUID
    public var name: String
    public var hospital: String
    public var specialty: String
    public var waitMinutes: Int
    public var rating: Double
    public var languages: [String]
    public var status: Status

    public init(
        id: UUID = UUID(),
        name: String,
        hospital: String,
        specialty: String,
        waitMinutes: Int,
        rating: Double,
        languages: [String],
        status: Status
    ) {
        self.id = id
        self.name = name
        self.hospital = hospital
        self.specialty = specialty
        self.waitMinutes = waitMinutes
        self.rating = rating
        self.languages = languages
        self.status = status
    }
}

public struct ConsultationSession: Identifiable, Codable, Sendable, Equatable {
    public enum Status: String, Codable, Sendable {
        case waiting, connecting, inConsultation, escalated, completed
    }

    public let id: UUID
    public var conversationId: UUID
    public var vet: VetAvailability
    public var ownerId: UUID
    public var petName: String
    public var status: Status
    public var createdAt: Date
    public var estimatedWaitMinutes: Int
    public var escalatesAt: Date

    public init(
        id: UUID = UUID(),
        conversationId: UUID = UUID(),
        vet: VetAvailability,
        ownerId: UUID,
        petName: String,
        status: Status = .waiting,
        createdAt: Date = Date(),
        estimatedWaitMinutes: Int,
        escalatesAt: Date
    ) {
        self.id = id
        self.conversationId = conversationId
        self.vet = vet
        self.ownerId = ownerId
        self.petName = petName
        self.status = status
        self.createdAt = createdAt
        self.estimatedWaitMinutes = estimatedWaitMinutes
        self.escalatesAt = escalatesAt
    }
}
