# PetReady Multi-App Folder Structure (Phase 1)

The repository now mirrors the structure below. Treat this as the canonical layout when you create new files or explain the project to stakeholders.

```
PetReady-Ecosystem/
├── PetReady-Owner/                     # Consumer app (folder name: PetReadyOwner/)
│   ├── App/
│   │   └── PetReadyOwnerApp.swift
│   ├── Features/
│   │   ├── Auth/         # Owner login/signup flow
│   │   ├── Home/         # Welcome hero + quick actions
│   │   ├── Pets/         # Pet list/detail placeholders
│   │   ├── Health/       # Vaccine/care timeline
│   │   ├── Clinics/      # Clinic discovery + filters
│   │   ├── Chat/         # Owner chat shells
│   │   ├── Info/         # Announcements + education
│   │   ├── Settings/     # Preferences + infra preview
│   │   └── Components/   # Shared owner UI helpers
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-VetPro/                    # Veterinary professional app (folder name: PetReadyVetPro/)
│   ├── App/
│   │   └── PetReadyVetProApp.swift
│   ├── Features/
│   │   ├── Auth/         # Vet/clinic application + login
│   │   ├── Dashboard/    # Professional overview
│   │   ├── Patients/     # Patient list cards
│   │   ├── Queue/        # Queue monitor mock
│   │   ├── Content/      # Educational content hub
│   │   ├── Settings/     # Practice + pricing forms
│   │   └── Components/   # Vet UI helpers
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-Rider/                     # Transport service app (folder name: PetReadyRider/)
│   ├── App/
│   │   └── PetReadyRiderApp.swift
│   ├── Features/
│   │   ├── Auth/         # Rider login/request access
│   │   ├── Dashboard/    # Rider hero + stats
│   │   ├── Jobs/         # Job list/filter UI
│   │   ├── Wallet/       # Money pocket preview
│   │   ├── Profile/      # Documents, vehicles, settings
│   │   └── Components/   # Rider UI helpers
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-CentralAdmin/              # Government oversight app (folder name: PetReadyCentralAdmin/)
│   ├── App/
│   │   └── PetReadyCentralAdminApp.swift
│   ├── Features/
│   │   ├── Auth/         # Admin login/request
│   │   ├── Dashboard/    # System overview
│   │   ├── Approvals/    # Firestore approvals queue
│   │   ├── Announcements/# Alert composer
│   │   ├── Analytics/    # Metrics cards
│   │   ├── Settings/     # Feature toggles + infra
│   │   └── Components/   # Admin UI helpers
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── SharedCode/                         # Common Swift package
│   ├── Models/
│   ├── Services/
│   ├── Utilities/
│   ├── Networking/
│   └── Resources/
├── Backend/                            # Server-side implementation
│   ├── API/
│   ├── WebSocket/
│   ├── Database/
│   ├── Authentication/
│   ├── PushNotifications/
│   └── Deployment/
└── Documentation/                      # Project documentation
    ├── Architecture/
    ├── API/
    ├── Deployment/
    └── UserGuides/
```

> Note: hyphenated labels (e.g., `PetReady-Owner/`) describe the logical grouping. The actual folder names inside the repo (`PetReadyOwner/`, `PetReadyVetPro/`, etc.) load into `PetReady.xcworkspace` automatically. Keep the content of each subfolder aligned with the tree above.
