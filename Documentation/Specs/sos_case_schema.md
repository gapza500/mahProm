# SOSCase Schema (Phase 2)

Authoritative fields for the SOS + Rider dispatch flow. Stored in Firestore for now; backend API can mirror this contract later.

## Entity
- `id` (UUID)
- `requesterId` (UUID, owner account)
- `riderId` (UUID?, assigned rider)
- `petId` (UUID?)
- `incidentType` (`injury|breathing|trauma|poisoning|heatStroke|transport|other`)
- `priority` (`routine|urgent|critical`)
- `pickup` (`{ latitude: Double, longitude: Double }`)
- `destination` (`{ latitude, longitude }?`)
- `contactNumber` (String?)
- `status` (`pending|awaitingAssignment|assigned|enRoute|arrived|completed|cancelled|declined`)
- `notes` (String?)
- `attachments` ([`{ id: UUID, url: URL, kind: photo|video|audio|document }`])
- `etaMinutes` (Int?)
- `distanceKm` (Double?)
- `lastKnownLocation` (`Coordinate?`)
- `events` ([`{ id: UUID, message: String, actor: String, timestamp: Date }`])
- `createdAt`, `updatedAt`, `syncedAt?`, `isDirty`

## Lifecycle (client-side stub)
1) Owner creates `SOSCase` with `status=pending` via `SOSService.createCase`.
2) Rider accepts → `status=assigned`, `riderId` set; en-route updates can include `etaMinutes`/`distanceKm` + `recordBeacon`.
3) Owner/Admin can cancel → `status=cancelled`.
4) Rider/Admin marks completion → `status=completed`.

## Notes
- Keep events short; they are rendered in admin + rider logs.
- Optional media is represented as URLs only (no binary handling yet).
- Reassignment reuses `acceptCase` with a new `riderId` and appends an event.***
