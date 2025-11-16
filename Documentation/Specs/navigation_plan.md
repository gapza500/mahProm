# PetReady Navigation & Tab Plan

This guide summarizes the high-level navigation for every app in Phase 1 so teams can divide work with confidence.

## Owner App (PetReady Owner)
- **Tab bar (7 items)**: Home, Pets, Health, Clinics, Chat, Info, Settings.
- **Home tab**: Hero card, metric grid, quick actions, upcoming care, SOS toolkit.
- **Other tabs**: Each provides nested NavigationStack flows for CRUD, maps, chat history, and profile controls.

## VetPro App
- **Tab bar (5 items)**:
  1. Dashboard (role switch inline for Vet vs Clinic Admin)
  2. Patients (list/detail, medical history)
  3. Queue (live chat queue + escalation controls)
  4. Content (campaigns, educational posts)
  5. Settings/Profile
- Vet vs admin modes reuse card-based sections to keep UX consistent.

## Rider App
- **Tab bar (4 items)**:
  1. Dashboard (hero, stats, active mission, quick cards)
  2. Jobs (available + scheduled jobs list)
  3. Wallet (earnings summary, payouts)
  4. Profile (documents, vehicle info, service areas)

## Central Admin App
- **Tab bar (5 items)**:
  1. Dashboard (system metrics, SOS overview)
  2. Approvals (vet + rider onboarding queues)
  3. Announcements (drafts + published alerts)
  4. Analytics (uptime, usage charts)
  5. Settings (team, regions, feature flags)

All tabs live in `ContentView.swift` of each target and use modern ScrollView card layouts with `NavigationStack` for drill-down flows. Refer to these plans before adding features to keep navigation aligned across apps.
