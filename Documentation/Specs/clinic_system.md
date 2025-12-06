# Clinic & Healthcare System Spec (Phase 2)

## Scope
- **Owner app**
  - Nearby clinics map/list driven by `ClinicService`.
  - Clinic detail screen exposing services, contact info, and booking button.
  - Appointment booking form -> writes via `AppointmentService`.
  - Health tab shows vaccine/treatment timeline from `HealthRecordService` and exposes shareable Health QR.

- **VetPro app**
  - “Clinic Appointments” screen listing pending/approved requests.
  - Actions: approve/decline (updates shared appointment status).

## Data contracts

### Clinic
```
Clinic {
  id: UUID
  name: String
  address: String
  coordinate: { latitude, longitude }
  specialty?: String
  rating?: Double
  reviewCount?: Int
  services?: [String]
  operatingHours?: String
  verificationStatus: String
  phone?: String
  email?: String
  website?: String
  distanceKm?: Double (computed client-side)
}
```

### Appointment
```
Appointment {
  id: UUID
  ownerId: UUID
  petId?: UUID
  clinicId: UUID
  date: Date
  status: pending|approved|declined|completed|cancelled
  reason?: String
  notes?: String
  createdAt: Date
  updatedAt: Date
}
```

### AppointmentRequest
```
AppointmentRequest {
  ownerId: UUID
  petId: UUID
  clinicId: UUID
  requestedDate: Date
  reason?: String
  notes?: String
}
```

### Health records
```
VaccineRecord {
  id: UUID
  petId: UUID
  vaccineType: String
  date: Date
  nextDue?: Date
  clinicId?: UUID
  vetId?: UUID
}

TreatmentRecord {
  id: UUID
  petId: UUID
  title: String
  detail: String
  performedAt: Date
  followUpDate?: Date
  clinicId?: UUID
  vetId?: UUID
}
```

## Services
- `ClinicService.listNearbyClinics(lat, lon, radiusKm)` → `[Clinic]` (currently stubbed + distance calculation).
- `AppointmentService`
  - `requestAppointment(AppointmentRequest) -> Appointment`
  - `fetchAppointments(ownerId)`
  - `fetchClinicAppointments(clinicId)`
  - `updateStatus(appointmentId, status, notes)`
- `HealthRecordService`
  - `fetchVaccines(petId)`
  - `fetchTreatments(petId)`
  - In-memory seed data + append helpers until Firestore backend lands.

## UI flows
1. Owner opens Clinics tab
   - LocationService snapshot seeding `Map` region
   - Clinics fetched, list + map updated
   - Selecting a clinic pushes detail screen
2. Booking
   - Owner picks pet, date/time, reason
   - AppointmentService creates `pending` record
   - Confirmation toast + Health tab picks up “upcoming care” from same service
3. VetPro clinic admin
   - Pulls `fetchClinicAppointments` for their clinic identity
   - Approve/decline updates status; owners see real-time change
4. Health QR
   - HealthQRView generates QR payload summarizing pet + vaccines using QRService
   - Ready for scanning in clinics / government checkpoints

## Notes / Follow-ups
- Replace in-memory services with Firestore collections (`clinics`, `appointments`, `healthRecords`) in Phase 2b once backend endpoints are ready.
- Add push notifications for appointment approval (owner) + new request (clinic).
- Hook vet approvals into Central Admin oversight (analytics + feature flags).
