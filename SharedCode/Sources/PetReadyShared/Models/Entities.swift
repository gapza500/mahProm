import Foundation

public struct Coordinate: Codable, Equatable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum UserType: String, Codable {
    case owner, vet, clinic, admin, rider, tester
}

public enum UserApprovalStatus: String, Codable {
    case pending, approved, rejected
}

public struct UserProfile: Identifiable, Codable {
    public let id: String
    public var displayName: String
    public var email: String
    public var phone: String?
    public var role: UserType
    public var status: UserApprovalStatus
    public var createdAt: Date?

    public init(
        id: String,
        displayName: String,
        email: String,
        phone: String? = nil,
        role: UserType,
        status: UserApprovalStatus,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.phone = phone
        self.role = role
        self.status = status
        self.createdAt = createdAt
    }
}

public struct User: Identifiable, Codable, Equatable {
    public let id: UUID
    public var userType: UserType
    public var displayName: String
    public var phone: String
    public var email: String
    public var verificationStatus: String
    public var createdAt: Date
    public var updatedAt: Date
    public var syncedAt: Date?
    public var isDirty: Bool

    public init(
        id: UUID = UUID(),
        userType: UserType,
        displayName: String,
        phone: String,
        email: String,
        verificationStatus: String = "pending",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncedAt: Date? = nil,
        isDirty: Bool = false
    ) {
        self.id = id
        self.userType = userType
        self.displayName = displayName
        self.phone = phone
        self.email = email
        self.verificationStatus = verificationStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncedAt = syncedAt
        self.isDirty = isDirty
    }
}

public struct Pet: Identifiable, Codable, Equatable {
    public enum Species: String, Codable { case dog, cat, rabbit, bird, other }

    public let id: UUID
    public var ownerId: UUID
    public var species: Species
    public var breed: String
    public var name: String
    public var sex: String
    public var dob: Date?
    public var weight: Double?
    public var barcodeId: String?
    public var microchipCode: String?
    public var status: String
    public var updatedAt: Date
    public var syncedAt: Date?
    public var isDirty: Bool

    public init(
        id: UUID = UUID(),
        ownerId: UUID,
        species: Species,
        breed: String = "",
        name: String,
        sex: String = "unknown",
        dob: Date? = nil,
        weight: Double? = nil,
        barcodeId: String? = nil,
        microchipCode: String? = nil,
        status: String = "active",
        updatedAt: Date = Date(),
        syncedAt: Date? = nil,
        isDirty: Bool = false
    ) {
        self.id = id
        self.ownerId = ownerId
        self.species = species
        self.breed = breed
        self.name = name
        self.sex = sex
        self.dob = dob
        self.weight = weight
        self.barcodeId = barcodeId
        self.microchipCode = microchipCode
        self.status = status
        self.updatedAt = updatedAt
        self.syncedAt = syncedAt
        self.isDirty = isDirty
    }
}

public struct Barcode: Identifiable, Codable {
    public let id: UUID
    public var petId: UUID
    public var codeText: String
    public var type: String
    public var issuedAt: Date
    public var revokedAt: Date?

    public init(
        id: UUID = UUID(),
        petId: UUID,
        codeText: String,
        type: String,
        issuedAt: Date = Date(),
        revokedAt: Date? = nil
    ) {
        self.id = id
        self.petId = petId
        self.codeText = codeText
        self.type = type
        self.issuedAt = issuedAt
        self.revokedAt = revokedAt
    }
}

public struct VaccineRecord: Identifiable, Codable {
    public let id: UUID
    public var petId: UUID
    public var clinicId: UUID?
    public var vetId: UUID?
    public var vaccineType: String
    public var date: Date
    public var nextDue: Date?
    public var updatedAt: Date
    public var syncedAt: Date?
    public var isDirty: Bool

    public init(
        id: UUID = UUID(),
        petId: UUID,
        clinicId: UUID? = nil,
        vetId: UUID? = nil,
        vaccineType: String,
        date: Date = Date(),
        nextDue: Date? = nil,
        updatedAt: Date = Date(),
        syncedAt: Date? = nil,
        isDirty: Bool = false
    ) {
        self.id = id
        self.petId = petId
        self.clinicId = clinicId
        self.vetId = vetId
        self.vaccineType = vaccineType
        self.date = date
        self.nextDue = nextDue
        self.updatedAt = updatedAt
        self.syncedAt = syncedAt
        self.isDirty = isDirty
    }
}

public struct Reminder: Identifiable, Codable {
    public let id: UUID
    public var petId: UUID
    public var userId: UUID
    public var type: String
    public var fireDate: Date
    public var status: String
    public var updatedAt: Date
    public var syncedAt: Date?
    public var isDirty: Bool
}

public struct Clinic: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var address: String
    public var coordinate: Coordinate
    public var servicesJSON: String
    public var operatingHours: String
    public var verificationStatus: String
}

public struct Appointment: Identifiable, Codable {
    public let id: UUID
    public var petId: UUID
    public var clinicId: UUID
    public var date: Date
    public var status: String
}

public struct Conversation: Identifiable, Codable {
    public let id: UUID
    public var petId: UUID
    public var ownerId: UUID
    public var vetId: UUID
    public var status: String
    public var createdAt: Date
    public var endedAt: Date?
}

public struct Message: Identifiable, Codable {
    public let id: UUID
    public var conversationId: UUID
    public var senderId: UUID
    public var senderType: UserType
    public var text: String
    public var createdAt: Date
}

public struct SOSCase: Identifiable, Codable {
    public let id: UUID
    public var requesterId: UUID
    public var riderId: UUID?
    public var petId: UUID
    public var status: String
    public var createdAt: Date
    public var updatedAt: Date
}

public struct GovernmentAnnouncement: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var content: String
    public var type: String
    public var priority: String
    public var targetAudience: String
    public var publishedAt: Date
}
