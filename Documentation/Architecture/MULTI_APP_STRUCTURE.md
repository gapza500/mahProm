# PetReady Multi-App Folder Structure (Phase 1)

The repository now mirrors the structure below. Treat this as the canonical layout when you create new files or explain the project to stakeholders.

```
PetReady-Ecosystem/
├── PetReady-Owner/                     # Consumer app (folder name: PetReadyOwner/)
│   ├── App/
│   │   └── PetReadyOwnerApp.swift
│   ├── Features/
│   │   ├── Auth/
│   │   ├── Home/
│   │   ├── Pets/
│   │   ├── Health/
│   │   ├── Clinics/
│   │   ├── Chat/
│   │   ├── Info/
│   │   ├── Settings/
│   │   └── Components/
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-VetPro/                    # Veterinary professional app (folder name: PetReadyVetPro/)
│   ├── App/
│   │   └── PetReadyVetProApp.swift
│   ├── Features/
│   │   ├── Auth/
│   │   ├── Dashboard/
│   │   ├── Patients/
│   │   ├── Queue/
│   │   ├── Content/
│   │   ├── Settings/
│   │   └── Components/
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-Rider/                     # Transport service app (folder name: PetReadyRider/)
│   ├── App/
│   │   └── PetReadyRiderApp.swift
│   ├── Features/
│   │   ├── Auth/
│   │   ├── Dashboard/
│   │   ├── Jobs/
│   │   ├── Wallet/
│   │   ├── Profile/
│   │   └── Components/
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-CentralAdmin/              # Government oversight app (folder name: PetReadyCentralAdmin/)
│   ├── App/
│   │   └── PetReadyCentralAdminApp.swift
│   ├── Features/
│   │   ├── Auth/
│   │   ├── Dashboard/
│   │   ├── Approvals/
│   │   ├── Announcements/
│   │   ├── Analytics/
│   │   ├── Settings/
│   │   └── Components/
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
