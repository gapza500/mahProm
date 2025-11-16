# CloudKit Setup Guide (Phase 1)

1. Sign in to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/).
2. Create container `iCloud.com.petready.shared` and add it to every Xcode target.
3. Define record types: `User`, `Pet`, `Clinic`, `Appointment`, `Conversation`, `Message`, `SOSCase`, `GovernmentAnnouncement`.
4. Enable public + private databases; add default fields (`updatedAt`, `syncedAt`, `isDirty`).
5. Configure subscriptions for:
   - `Conversation` (new message push)
   - `SOSCase` (status changes)
   - `GovernmentAnnouncement` (publish/expire).
6. In each app target, enable iCloud + CloudKit capabilities pointing to the shared container.
7. Verify by running `cloudkitctl status --container iCloud.com.petready.shared` and ensuring schema deployed.
