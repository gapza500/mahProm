import Foundation

@MainActor
public protocol HealthRecordServiceProtocol {
    func fetchVaccines(petId: UUID) async -> [VaccineRecord]
    func fetchTreatments(petId: UUID) async -> [TreatmentRecord]
    func addVaccine(_ record: VaccineRecord) async
    func addTreatment(_ record: TreatmentRecord) async
}

@MainActor
public final class HealthRecordService: HealthRecordServiceProtocol {
    public static let shared = HealthRecordService()

    private var vaccineStore: [UUID: [VaccineRecord]] = [:]
    private var treatmentStore: [UUID: [TreatmentRecord]] = [:]

    public init() {}

    public func fetchVaccines(petId: UUID) async -> [VaccineRecord] {
        if vaccineStore[petId] == nil {
            seedVaccines(for: petId)
        }
        return (vaccineStore[petId] ?? []).sorted { lhs, rhs in
            (lhs.nextDue ?? lhs.date) < (rhs.nextDue ?? rhs.date)
        }
    }

    public func fetchTreatments(petId: UUID) async -> [TreatmentRecord] {
        if treatmentStore[petId] == nil {
            seedTreatments(for: petId)
        }
        return (treatmentStore[petId] ?? []).sorted { $0.performedAt > $1.performedAt }
    }

    public func addVaccine(_ record: VaccineRecord) async {
        var records = vaccineStore[record.petId] ?? []
        records.append(record)
        vaccineStore[record.petId] = records
    }

    public func addTreatment(_ record: TreatmentRecord) async {
        var records = treatmentStore[record.petId] ?? []
        records.append(record)
        treatmentStore[record.petId] = records
    }

    private func seedVaccines(for petId: UUID) {
        let sample = [
            VaccineRecord(
                petId: petId,
                clinicId: UUID(),
                vetId: UUID(),
                vaccineType: "Rabies Booster",
                date: Calendar.current.date(byAdding: .month, value: -10, to: Date()) ?? Date(),
                nextDue: Calendar.current.date(byAdding: .day, value: 20, to: Date())
            ),
            VaccineRecord(
                petId: petId,
                clinicId: UUID(),
                vetId: UUID(),
                vaccineType: "DHPPi",
                date: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                nextDue: Calendar.current.date(byAdding: .month, value: 6, to: Date())
            )
        ]
        vaccineStore[petId] = sample
    }

    private func seedTreatments(for petId: UUID) {
        let sample = [
            TreatmentRecord(
                petId: petId,
                clinicId: UUID(),
                vetId: UUID(),
                title: "Dermatitis Check-up",
                detail: "Topical treatment prescribed for 7 days.",
                performedAt: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
                followUpDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
            ),
            TreatmentRecord(
                petId: petId,
                clinicId: UUID(),
                vetId: UUID(),
                title: "General Wellness Exam",
                detail: "Routine exam with dental cleaning.",
                performedAt: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
                followUpDate: nil
            )
        ]
        treatmentStore[petId] = sample
    }
}
