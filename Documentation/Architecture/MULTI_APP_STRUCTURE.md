# PetReady Multi-App Folder Structure (Phase 1)

The repository now mirrors the structure below. Treat this as the canonical layout when you create new files or explain the project to stakeholders.

```
PetReady-Ecosystem/
├── PetReady-Owner/                     # Consumer app (folder name: PetReadyOwner/)
│   ├── App/
│   │   └── PetReadyOwnerApp.swift
│   ├── Views/
│   │   ├── Auth/
│   │   ├── Homepage/
│   │   ├── Pet/
│   │   ├── Health/
│   │   ├── Clinic/
│   │   ├── Chat/
│   │   ├── Information/
│   │   └── Settings/
│   ├── ViewModels/
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-VetPro/                    # Veterinary professional app (folder name: PetReadyVetPro/)
│   ├── App/
│   │   └── PetReadyVetProApp.swift
│   ├── Views/
│   │   ├── Auth/
│   │   ├── VetMode/
│   │   ├── ClinicAdminMode/
│   │   ├── Patients/
│   │   ├── Consultations/
│   │   └── Analytics/
│   ├── ViewModels/
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-Rider/                     # Transport service app (folder name: PetReadyRider/)
│   ├── App/
│   │   └── PetReadyRiderApp.swift
│   ├── Views/
│   │   ├── Auth/
│   │   ├── Dashboard/
│   │   ├── Jobs/
│   │   ├── Navigation/
│   │   ├── MoneyPocket/
│   │   └── Profile/
│   ├── ViewModels/
│   ├── Services/
│   ├── Resources/
│   └── Tests/
├── PetReady-CentralAdmin/              # Government oversight app (folder name: PetReadyCentralAdmin/)
│   ├── App/
│   │   └── PetReadyCentralAdminApp.swift
│   ├── Views/
│   │   ├── Dashboard/
│   │   ├── UserManagement/
│   │   ├── ProblemResolution/
│   │   ├── SystemMonitoring/
│   │   ├── ContentControl/
│   │   └── Analytics/
│   ├── ViewModels/
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
