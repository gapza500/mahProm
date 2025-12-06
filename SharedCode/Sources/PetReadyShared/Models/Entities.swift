import Foundation

public struct Coordinate: Codable, Equatable, Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public extension Coordinate {
    func distanceKm(to other: Coordinate) -> Double {
        let earthRadius = 6371.0
        let dLat = (other.latitude - latitude) * .pi / 180
        let dLon = (other.longitude - longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(latitude * .pi / 180) *
            cos(other.latitude * .pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
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

public struct Pet: Identifiable, Codable, Equatable, Sendable {
    public enum Species: String, Codable { case dog, cat, rabbit, bird, other }

    public let id: UUID
    public var ownerId: UUID?
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
        ownerId: UUID? = nil,
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

public struct TreatmentRecord: Identifiable, Codable, Sendable {
    public let id: UUID
    public var petId: UUID
    public var clinicId: UUID?
    public var vetId: UUID?
    public var title: String
    public var detail: String
    public var performedAt: Date
    public var followUpDate: Date?
    public var updatedAt: Date
    public var syncedAt: Date?
    public var isDirty: Bool

    public init(
        id: UUID = UUID(),
        petId: UUID,
        clinicId: UUID? = nil,
        vetId: UUID? = nil,
        title: String,
        detail: String,
        performedAt: Date = Date(),
        followUpDate: Date? = nil,
        updatedAt: Date = Date(),
        syncedAt: Date? = nil,
        isDirty: Bool = false
    ) {
        self.id = id
        self.petId = petId
        self.clinicId = clinicId
        self.vetId = vetId
        self.title = title
        self.detail = detail
        self.performedAt = performedAt
        self.followUpDate = followUpDate
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

public struct Clinic: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var address: String
    public var coordinate: Coordinate
    public var specialty: String?
    public var rating: Double?
    public var reviewCount: Int?
    public var services: [String]?
    public var operatingHours: String?
    public var verificationStatus: String
    public var phone: String?
    public var email: String?
    public var website: String?
    public var distanceKm: Double?

    public init(
        id: UUID = UUID(),
        name: String,
        address: String,
        coordinate: Coordinate,
        specialty: String? = nil,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        services: [String]? = nil,
        operatingHours: String? = nil,
        verificationStatus: String = "pending",
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil,
        distanceKm: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.specialty = specialty
        self.rating = rating
        self.reviewCount = reviewCount
        self.services = services
        self.operatingHours = operatingHours
        self.verificationStatus = verificationStatus
        self.phone = phone
        self.email = email
        self.website = website
        self.distanceKm = distanceKm
    }

    public static func == (lhs: Clinic, rhs: Clinic) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum AppointmentStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case approved
    case declined
    case completed
    case cancelled

    public var readableLabel: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .declined: return "Declined"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

public struct Appointment: Identifiable, Codable, Sendable {
    public let id: UUID
    public var ownerId: UUID
    public var petId: UUID?
    public var clinicId: UUID
    public var date: Date
    public var status: AppointmentStatus
    public var reason: String?
    public var notes: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        ownerId: UUID,
        petId: UUID? = nil,
        clinicId: UUID,
        date: Date,
        status: AppointmentStatus = .pending,
        reason: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerId = ownerId
        self.petId = petId
        self.clinicId = clinicId
        self.date = date
        self.status = status
        self.reason = reason
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct AppointmentRequest: Sendable {
    public var ownerId: UUID
    public var petId: UUID?
    public var clinicId: UUID
    public var requestedDate: Date
    public var reason: String?
    public var notes: String?

    public init(
        ownerId: UUID,
        petId: UUID? = nil,
        clinicId: UUID,
        requestedDate: Date,
        reason: String? = nil,
        notes: String? = nil
    ) {
        self.ownerId = ownerId
        self.petId = petId
        self.clinicId = clinicId
        self.requestedDate = requestedDate
        self.reason = reason
        self.notes = notes
    }
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

public struct SOSEvent: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let message: String
    public let actor: String
    public let timestamp: Date

    public init(id: UUID = UUID(), message: String, actor: String, timestamp: Date = Date()) {
        self.id = id
        self.message = message
        self.actor = actor
        self.timestamp = timestamp
    }
}

public struct SOSAttachment: Identifiable, Codable, Equatable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case photo
        case video
        case audio
        case document
    }

    public let id: UUID
    public var url: URL
    public var kind: Kind

    public init(id: UUID = UUID(), url: URL, kind: Kind = .photo) {
        self.id = id
        self.url = url
        self.kind = kind
    }
}

public enum SOSIncidentType: String, Codable, CaseIterable, Sendable {
    case injury
    case breathing
    case trauma
    case poisoning
    case heatStroke
    case transport
    case other
}

public enum SOSPriority: String, Codable, CaseIterable, Sendable {
    case routine
    case urgent
    case critical

    public var readableLabel: String {
        switch self {
        case .routine: return "Routine"
        case .urgent: return "Urgent"
        case .critical: return "Critical"
        }
    }
}

public enum SOSStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case awaitingAssignment
    case assigned
    case enRoute
    case arrived
    case completed
    case cancelled
    case declined
}

public struct SOSCase: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var requesterId: UUID
    public var riderId: UUID?
    public var petId: UUID?
    public var clinicId: UUID?
    public var incidentType: SOSIncidentType
    public var priority: SOSPriority
    public var pickup: Coordinate
    public var destination: Coordinate?
    public var contactNumber: String?
    public var status: SOSStatus
    public var notes: String?
    public var attachments: [SOSAttachment]
    public var etaMinutes: Int?
    public var distanceKm: Double?
    public var lastKnownLocation: Coordinate?
    public var events: [SOSEvent]
    public var createdAt: Date
    public var updatedAt: Date
    public var syncedAt: Date?
    public var isDirty: Bool

    public init(
        id: UUID = UUID(),
        requesterId: UUID,
        riderId: UUID? = nil,
        petId: UUID? = nil,
        clinicId: UUID? = nil,
        incidentType: SOSIncidentType,
        priority: SOSPriority = .urgent,
        pickup: Coordinate,
        destination: Coordinate? = nil,
        contactNumber: String? = nil,
        status: SOSStatus = .pending,
        notes: String? = nil,
        attachments: [SOSAttachment] = [],
        etaMinutes: Int? = nil,
        distanceKm: Double? = nil,
        lastKnownLocation: Coordinate? = nil,
        events: [SOSEvent] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncedAt: Date? = nil,
        isDirty: Bool = false
    ) {
        self.id = id
        self.requesterId = requesterId
        self.riderId = riderId
        self.petId = petId
        self.clinicId = clinicId
        self.incidentType = incidentType
        self.priority = priority
        self.pickup = pickup
        self.destination = destination
        self.contactNumber = contactNumber
        self.status = status
        self.notes = notes
        self.attachments = attachments
        self.etaMinutes = etaMinutes
        self.distanceKm = distanceKm
        self.lastKnownLocation = lastKnownLocation
        self.events = events
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncedAt = syncedAt
        self.isDirty = isDirty
    }
}

public struct SOSRequest: Equatable, Sendable {
    public var requesterId: UUID
    public var petId: UUID?
    public var incidentType: SOSIncidentType
    public var priority: SOSPriority
    public var pickup: Coordinate
    public var destination: Coordinate?
    public var clinicId: UUID?
    public var contactNumber: String?
    public var notes: String?
    public var attachmentURLs: [URL]

    public init(
        requesterId: UUID,
        petId: UUID? = nil,
        incidentType: SOSIncidentType,
        priority: SOSPriority = .urgent,
        pickup: Coordinate,
        destination: Coordinate? = nil,
        clinicId: UUID? = nil,
        contactNumber: String? = nil,
        notes: String? = nil,
        attachmentURLs: [URL] = []
    ) {
        self.requesterId = requesterId
        self.petId = petId
        self.incidentType = incidentType
        self.priority = priority
        self.pickup = pickup
        self.destination = destination
        self.clinicId = clinicId
        self.contactNumber = contactNumber
        self.notes = notes
        self.attachmentURLs = attachmentURLs
    }
}

public struct GovernmentAnnouncement: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var content: String
    public var type: String
    public var priority: String
    public var targetAudience: String
    public var publishedAt: Date
    public var clinicId: UUID?

    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        type: String = "general",
        priority: String = "normal",
        targetAudience: String = "all",
        publishedAt: Date = Date(),
        clinicId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.type = type
        self.priority = priority
        self.targetAudience = targetAudience
        self.publishedAt = publishedAt
        self.clinicId = clinicId
    }
}
