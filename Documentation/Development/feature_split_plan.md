# Feature-Based Refactor Plan

## Goals
- Keep `ContentView.swift` in each app focused on wiring tabs + shared dependencies.
- Move every tab/feature into its own folder with dedicated view + helpers so multiple people can edit without merge conflicts.
- Centralize shared styling helpers per app (e.g., cute cards for Owner) instead of redefining them inline.
- Keep functionality identical after the split: barcode flows, Firebase repositories, and dashboard feeds must behave exactly as before.

## Structure Blueprint
```
PetReadyOwner/PetReadyOwner/
├── Features/
│   ├── Components/        // shared styling/helpers for this target
│   ├── Home/
│   ├── Pets/
│   ├── Health/
│   ├── Clinics/
│   ├── Chat/
│   ├── Info/
│   └── Settings/
└── ContentView.swift      // TabView only, imports feature entry points
```
Apply the same pattern for VetPro (Dashboard, Patients, Queue, Content, Settings), Rider (Dashboard, Jobs, Wallet, Profile), and CentralAdmin (Dashboard, Approvals, Alerts, Analytics, Settings).

Each feature folder contains:
- `FeatureView.swift` – public entry view used by `ContentView`.
- Optional `FeatureViewModel.swift` – state + logic per feature.
- Optional `Components/` for feature-specific subviews.

## Status
- ✅ Owner app migrated to the new structure; shared helpers moved into `Features/Components/OwnerUIComponents.swift`.
- 🔜 Repeat the process for VetPro/Rider/CentralAdmin to unblock parallel edits.
- 🔜 Share Xcode schemes so every developer sees all four targets automatically (`Product > Scheme > Manage Schemes… -> Shared`).

## Next Steps
1. Clone the Owner folder layout for the remaining apps.
2. Extract any shared styling utilities (e.g., Rider gradients) into their own `Components` files.
3. Once all features are modular, consider introducing per-feature view models + protocols to move mock data out of views.
4. Update lint/build scripts to watch the new directories.
