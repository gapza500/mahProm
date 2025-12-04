# PetReady Multi-App Folder Structure (Phase 1 Snapshot)

This document reflects the current folder layout that ships with the Phase 1 foundation (auth polish, shared services, design system). Use it as the source of truth when navigating the repo or adding new modules.

## 1. Root Layout

```
PetReady-Ecosystem/
├── Backend/                     # Node/Express API + Socket.IO hub
├── Config/                      # YAML/env/feature-flag files
├── Documentation/               # Specs, plans, status trackers (this file)
├── PetReady.xcworkspace         # Umbrella workspace referencing every target
├── PetReadyOwner/               # Owner iOS app
├── PetReadyVetPro/              # Vet/Clinic iOS app
├── PetReadyRider/               # Rider/Transport iOS app
├── PetReadyCentralAdmin/        # Government/Admin iOS app
├── SharedCode/                  # Swift Package consumed by all targets
├── Scripts/                     # build/test/deploy helpers
├── Tools/                       # CLI + automation utilities
├── Package.swift                # SwiftPM manifest for SharedCode
└── README.md                    # Ecosystem overview + roadmap
```

Key conventions:

- All buildable apps live in their own folder with `*.xcodeproj`, `App/` entry points, and `Features/` folders grouping SwiftUI surfaces.
- Shared SwiftUI styles, services, and utilities are delivered via the SwiftPM package so we can evolve in one place.
- Documentation is split by purpose (`Development/`, `Architecture/`, `Guidelines/`, etc.) but linked from README.

## 2. SharedCode Package

```
SharedCode/
└── Sources/PetReadyShared/
    ├── App/
    │   └── AppBootstrap.swift           # Firebase / global setup
    ├── DesignSystem/                    # NEW: semantic colors, gradients, metrics
    ├── Models/                          # UserProfile, Pet, Request, etc.
    ├── Services/                        # AuthService, LocationService, Push, Realtime…
    ├── Repositories/                    # Firestore + future data stores
    ├── Utilities/                       # KeychainService, ImageCache, etc.
    ├── Views/                           # Shared UI (auth, placeholders, infrastructure preview)
    └── ViewModels/                      # Shared observable objects (where needed)
```

Highlights:

- `DesignSystem/DesignSystem.swift` exposes `DesignSystem.Colors` / `Gradients` / `Metrics` so every target pulls styles from a single source (light + dark variants baked in).
- `Views/Auth` contains `FirebaseEmailLoginView`, `AuthFeedbackBanner`, and other reusable surfaces.
- `Views/Infrastructure/InfrastructurePreviewView` stitches together the mock GPS + realtime + push services.

## 3. App Targets

Each app follows the same high-level layout:

```
PetReadyOwner/
├── PetReadyOwner.xcodeproj
└── PetReadyOwner/
    ├── App/                 # @main entry + Info.plist
    ├── Features/            # Feature folders (Auth, Home, Pets, Clinics, etc.)
    │   └── Components/      # App-specific view helpers
    ├── Assets.xcassets
    └── GoogleService-Info.plist
```

- **Owner** tabs: Home, Pets, Health, Clinics, Chat, Info, Settings. Each feature folder contains the SwiftUI screens plus styling helpers built on top of the design system.
- **VetPro** tabs: Dashboard, Patients, Queue, Content, Settings. Includes `Components/` (e.g., `vetCuteCard`) and now uses the shared tokens by importing `PetReadyShared`.
- **Rider** tabs: Dashboard, Jobs, Wallet, Profile. Jobs include the new `RiderJobFilterView`, and settings/profile link to the infrastructure preview.
- **CentralAdmin** tabs: Dashboard, Approvals, Alerts, Analytics, Settings. Placeholder navigation is wired everywhere so admins can preview upcoming flows.

> Tip: whenever you add gradients, background colors, or reusable styles inside `Features/Components`, import `PetReadyShared` and reference `DesignSystem` tokens instead of hard-coded hex values.

## 4. Supporting Directories

- **Backend/** — Express server with modular routers, Socket.IO hub, and configuration scripts. Seasoned via `npm` scripts in `package.json`.
- **Scripts/** — Shell helpers (`build-all.sh`, `test-all.sh`, `integration-tests.sh`, etc.) pinned to the latest simulator destination.
- **Documentation/** — Everything from `PHASE1_STATUS.md` to specs (`Documentation/Specs/petready_spec.md`) and architecture notes.
- **Tools/** — Home for CLI utilities, Fastlane lanes, lint configs, etc. (stubs today, ready for Phase 2/CI).

## 5. Phase 1 Alignment Checklist

- [x] All four apps import `PetReadyShared`.
- [x] Shared design tokens live under `SharedCode/Sources/PetReadyShared/DesignSystem`.
- [x] `InfrastructurePreviewView` is reachable from each app’s settings/profile section.
- [x] README + this doc describe the current layout so onboarding engineers know where to plug new work.

As we enter Phase 2, update this document whenever directories move or major modules are added—treat it like the repo’s “map legend.” It keeps onboarding smooth and ensures every feature team knows where to place new code.***
