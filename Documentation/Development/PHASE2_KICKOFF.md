# Phase 2 Kickoff (Core Features)

Phase 1 foundation is locked. Phase 2 is where we add the first "real" features on top of the shared services. We split responsibilities between the Owner experience and Government (CentralAdmin) experience.

## Owner Experience (You)
Focus on delivering a vertical slice for pet owners so we can exercise the barcode/health/clinic stack.

1. **Barcode/QR Flow**
   - Replace placeholder buttons with a real scanner view (AVFoundation) and manual entry form.
   - Wire the result into Firestore (lookup + attach to profile) and surface validation states.
2. **Pet Profile Detail**
   - Build a detail screen fed by Firestore (name, species, timeline components).
   - Implement editable fields using the shared `PetService`.
3. **Health Timeline**
   - Fetch upcoming vaccines + treatments from Firestore and show them in `OwnerHealthView`.
   - Add reminder scheduling by calling into the new PushNotificationService.
4. **Clinics Map**
   - Use the upgraded LocationService + MapKit to show nearby clinics with distance badges.
   - Filter sheet should actually filter the list (persist toggles in `AppStorage`).

## Government Service Integration (Friend)
CentralAdmin needs to exercise the admin workflows; these tasks land in their backlog.

1. **Approvals with Real Data**
   - Hook the approvals tab to Firestore queries (pending users, status updates).
   - Add actions (approve/reject) and surface realtime status changes via the RealtimeSyncService.
2. **Announcements**
   - Build a CRUD interface for government alerts stored in Firestore (`announcements` collection).
   - Tie into the PushNotificationService to send test announcements to the Owner app.
3. **Analytics Dashboard**
   - Pull metrics from Firestore aggregates or the backend (pet registrations, SOS cases).
   - Surface charts/cards using existing Admin UI components.
4. **System Monitor**
   - Display live events (socket feed) such as new approvals, announcement broadcasts, errors, etc.

## Infra Tasks To Support Both
- Finalize Location/Realtime/Push integrations (Phase 1 Item #1).
- Add feature flags or configuration data under `Config/` for environment-specific URLs (Realtime + API base).
- Document API endpoints needed for the above flows in `Documentation/Specs/petready_spec.md`.

Keep this doc updated as stories move across the board. Once Phase 2 wraps, we’ll revisit dark-mode polish and final UX improvements in Phase 3.***
