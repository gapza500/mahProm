# PetReady Multi-App Ecosystem — README

PetReady is a comprehensive 4-app iPhone ecosystem (Swift 5.5+, SwiftUI, iOS 16+) that brings "หมอพร้อมสำหรับสัตว์เลี้ยง" to life as both a commercial pet healthcare platform and a government public service.

**Apps in the Ecosystem:**
- **PetReady Owner**: Main consumer app for pet owners with comprehensive pet management
- **PetReady VetPro**: Combined veterinary professional and clinic management app
- **PetReady Rider**: Transport service app for pet pickups and emergency dispatch
- **PetReady CentralAdmin**: Government/admin oversight app for system management and problem resolution

> TL;DR — We'll build a realistic multi-app ecosystem with barcode pet registration, digital health QR, smart vet chat with queuing, SOS dispatch with rider tracking, government service announcements, and central admin oversight. Final output is 4 compilable iOS apps with real backend integration, cloud database, and cross-app real-time synchronization.

---

## What this ecosystem is about
- **Problem:** Pet health records are scattered; veterinary access is limited; emergency pet transport is unreliable; government oversight of pet services is lacking.
- **Solution:** A comprehensive mobile ecosystem for **identity (barcode/QR)**, **health (vaccines + digital records)**, **care access (smart vet chat + clinic booking + transport)**, **emergency (SOS + rider dispatch)**, and **government services (public announcements + system oversight)**.
- **Platform:** 4-app iPhone ecosystem (iOS 16+), Swift 5.5+, SwiftUI with real-time cross-app synchronization.
- **Government Service Role:** Provides reliable public health announcements, emergency coordination, licensed professional verification, and system-wide problem resolution.

---

## What we're going to do (Multi-App Development Plan)

We'll develop this as a comprehensive 4-app ecosystem with realistic integrations and government service capabilities.

### Phase 1: Foundation & Structure
1. **Multi-App Architecture Setup**
   - 4 separate Xcode projects with shared code module
   - Real cloud database (CloudKit/Firebase) and WebSocket server
   - Cross-app authentication and user management
   - Shared models, services, and utilities

2. **Core Infrastructure**
   - Real phone/email authentication with verification
   - Push notification system across all apps
   - GPS tracking and real-time location services
   - Role-based access control and permissions

### Phase 2: Core Features (Feature-by-Feature)
3. **Pet Registration & Management**
   - Barcode/QR scanning with mock microchip simulation
   - Multi-species pet profiles with photos and documents
   - Digital health records and vaccination tracking
   - Government verification and digital signatures

4. **Smart Veterinary Communication**
   - Vet selection with availability and wait times
   - 15-minute auto-escalation algorithm
   - Real-time chat with WebSocket connectivity
   - Professional consultation management

5. **Clinic & Healthcare System**
   - Map-based clinic discovery with campaigns and promotions
   - Appointment booking and management
   - Educational content and government health announcements
   - Professional clinic administration tools

6. **Transport & Emergency Services**
   - SOS emergency dispatch with rider assignment
   - Real-time GPS tracking and ETA updates
   - Scheduled transport services (appointments, grooming, etc.)
   - Rider money pocket system and job management

7. **Government Service Integration**
   - Public health announcements and emergency alerts
   - Licensed professional verification and directory
   - Central admin oversight and problem resolution
   - System monitoring and analytics dashboard

### Phase 3: Advanced Features & Integration
8. **Real-time Synchronization**
   - Cross-app data synchronization
   - Live updates and notifications
   - Emergency response coordination
   - Performance monitoring and optimization

### Realistic Integration Elements:
- ✅ **Real Features**: Authentication, cloud database, WebSocket, GPS, push notifications
- 🎭 **Prototype Elements**: Mock microchip scanning, demo payment system, admin-approved vet verification
- 🏛️ **Government Services**: Public announcements, emergency coordination, professional licensing

---

## What you will get at the end (Final Deliverables)
- ✅ **4 compilable Xcode projects** forming a complete ecosystem:
  - **PetReady Owner**: Consumer app with pet management, health records, smart chat, and government information
  - **PetReady VetPro**: Professional app with dual Vet/Clinic Admin modes, patient management, and content creation
  - **PetReady Rider**: Transport app with job dispatch, GPS tracking, and money pocket system
  - **PetReady CentralAdmin**: Government oversight app with system monitoring, user management, and problem resolution

### Cross-App Features:
- **Real Authentication**: Phone/email verification with role-based access control
- **Real-time Communication**: WebSocket chat with smart queuing and 15-min auto-escalation
- **Emergency SOS**: Owner request → Rider assignment → Central Admin monitoring with live GPS tracking
- **Government Services**: Public announcements, emergency alerts, professional licensing verification
- **Cloud Integration**: Real cloud database with cross-app synchronization and offline support
- **Smart Transport**: GPS-optimized routing, multiple pickup coordination, ETA calculation
- **Live Admin Feed**: Central Admin dashboard displays the latest pet registrations in a Firestore-backed data table so ops can verify successful owner submissions instantly.

### Technical Capabilities:
- **Barcode/QR System**: Mock microchip simulation with government verification capabilities
- **Digital Health Records**: Complete vaccination history, treatment timelines, and document management
- **Professional Tools**: Clinic management, content creation, patient analytics, and staff coordination
- **Payment Prototype**: Money pocket system for transport services with transaction history
- **Analytics Dashboard**: System-wide monitoring, user behavior tracking, and performance metrics

### Documentation & Testing:
- 📄 **Comprehensive documentation** for all 4 apps with architecture diagrams and API specifications
- 🧪 **Cross-app integration tests** for real-time synchronization and emergency scenarios
- 🎯 **Government service reliability testing** for announcements and emergency response
- 🧭 **Barcode testing helper (debug builds)**: Any 4+ character barcode input is accepted for fast manual QA; production still expects the full `PET-<SPECIES>-####-######-AA` pattern and checksum.
- 📱 **Accessibility testing** (VoiceOver, Dynamic Type) and **localization** (TH/EN) across all apps
- 🚀 **Deployment guides** for App Store submission and backend service configuration

---

## Why barcode instead of real microchip?
We **simulate microchip** using **barcode/QR** so the ecosystem works day‑one with normal phone cameras.
The data model keeps a `microchipCode` field for future real‑chip integration—no refactor needed later.

---

## Multi-App Architecture Overview
- **Shared Code Module**: Common models, services, and networking used by all 4 apps
- **Individual App Architecture**: Each app uses MVVM with SwiftUI Views and ObservableObject ViewModels
- **Cross-App Communication**: Real-time WebSocket server and cloud database for synchronization
- **Role-Based Services**: Different service layers for each user type (Owner, Vet, Rider, Admin)
- **Government Integration**: Centralized announcement system and professional verification

### Key Technical Components:
- **Real-time Infrastructure**: WebSocket server, push notifications, GPS tracking
- **Cloud Services**: CloudKit/Firebase for data persistence and synchronization
- **Authentication**: Phone/email verification with role-based permissions
- **Payment Prototype**: Money pocket system for transport services
- **Professional Verification**: Admin approval workflow for vets and riders
- **Emergency Response**: SOS dispatch with live tracking and coordination

---

## Build & Run (Development Setup)

### Prerequisites
- Xcode 16+ with iOS 16+ simulators
- Apple Developer account for push notifications and CloudKit
- Backend server (Node.js/Firebase) for WebSocket and API services

### Multi-App Development
1. **Clone the repository** with all 4 app projects and shared code module
2. **Configure Backend**: Set up cloud database and WebSocket server
3. **Setup Shared Module**: Import SharedCode package into all 4 app projects
4. **Configure Authentication**: Set up phone/email verification services
5. **Run Each App**: Each app can be developed and tested independently

### Development Flows
**PetReady Owner App:**
- Register user → Add pets with barcode scanning → Issue digital QR
- Browse health history with vaccination records and treatment timelines
- Discover clinics with campaigns and educational content
- Start vet chat with smart queuing and wait time tracking
- Create SOS emergency requests with live rider tracking

**PetReady VetPro App:**
- Register as veterinary professional (admin approval required)
- Switch between Vet and Clinic Admin modes
- Manage patient consultations and chat queue
- Create educational content and manage clinic profile
- Access patient records and medical history

**PetReady Rider App:**
- Register as transport provider (admin approval required)
- Accept emergency SOS and scheduled transport jobs
- Use GPS navigation and route optimization
- Manage earnings with money pocket system
- Track job history and performance metrics

**PetReady CentralAdmin App:**
- System-wide monitoring and analytics
- User management and professional approval
- Government announcement creation and broadcasting
- Problem resolution and system diagnostics
- Emergency response coordination

> **Development Note**: All apps share the same backend and database for real-time synchronization and cross-app functionality.

---

## Role-Based Authentication & Approvals

Each app now wires into a shared Firebase Auth + Firestore profile system:

1. **Login surfaces**
   - Owner app includes combined email/password signup + login, plus Google Sign-In.
   - Rider, VetPro, and CentralAdmin apps expose “Request Access” flows (with optional Google sign-in) that create pending profiles.
2. **Profile document**
   - Every authenticated account must have `/users/{uid}` with `displayName`, `email`, `role`, and `status` (`pending/approved/rejected`).
   - Existing testers/admins should be seeded manually once; new signups write their own doc automatically.
3. **Approvals**
   - Central Admin → “Approvals” tab lists Firestore users with `status = pending`. Approving flips the status (and you can set custom claims via script/Cloud Function).
   - RoleGate automatically refreshes pending accounts every 10 seconds, so the user sees the approval without reinstalling.
4. **Security rules**
   - See `Documentation/Guidelines/firestore_rules_dev.md` for a starting rule set and instructions on setting `roles` claims.

_TL;DR_: seed the profile doc + claim, use the new login UI per app, approve from Central Admin, and the rest of the apps unlock themselves.

---

## Dark Appearance Support (upcoming)
- **Design parity**: All color tokens and gradients will be defined in SharedCode so both light/dark modes stay in sync.
- **Testing**: Each app will get a “Dark Mode QA” checklist before release (UI previews + simulator snapshots).
- **Docs**: The plan lives in `Documentation/Development/PHASE1_STATUS.md` (see “Dark Appearance Plan” row) and will expand as Phase 2 kicks off.

---

## Multi-App Folder Structure

```
PetReady-Ecosystem/
├── PetReady-Owner/                     # Consumer app
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
├── PetReady-VetPro/                    # Veterinary professional app
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
├── PetReady-Rider/                     # Transport service app
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
├── PetReady-CentralAdmin/              # Government oversight app
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
├── SharedCode/                         # Common code for all apps
│   ├── Models/                         # Shared data models
│   ├── Services/                       # Shared services (Auth, Networking, etc.)
│   ├── Utilities/                      # Common utilities and extensions
│   ├── Networking/                     # API client and WebSocket
│   └── Resources/                      # Shared assets and localization
├── Backend/                            # Server-side implementation
│   ├── API/                            # REST API endpoints
│   ├── WebSocket/                      # Real-time communication
│   ├── Database/                       # Cloud database schema
│   ├── Authentication/                 # Phone/email verification
│   ├── PushNotifications/              # Cross-app notifications
│   └── Deployment/                     # Cloud deployment configuration
└── Documentation/                      # Project documentation
    ├── Architecture/
    ├── API/
    ├── Deployment/
    └── UserGuides/
```

---

## Development Milestones & Success Criteria

### **Milestone 1: Foundation & Multi-App Architecture** (Weeks 1-3)
- **Goal**: Complete 4-app structure with shared code module and basic authentication
- **Success Criteria**: All 4 apps compile and run; shared code integration works; basic authentication functional

### **Milestone 2: Core Features & Pet Management** (Weeks 4-6)
- **Goal**: Pet registration, barcode scanning, digital QR, basic health records
- **Success Criteria**: Barcode scan <3s, QR generation in ≤3 taps, pet data syncs across apps

### **Milestone 3: Smart Communication & Clinic Integration** (Weeks 7-9)
- **Goal**: Vet chat with queuing, clinic discovery, appointment booking, content management
- **Success Criteria**: Chat latency <2s, 15-min auto-escalation works, appointments sync correctly

### **Milestone 4: Transport & Emergency Services** (Weeks 10-12)
- **Goal**: SOS dispatch, rider app functionality, GPS tracking, money pocket system
- **Success Criteria**: SOS response <5min, GPS accuracy <15m, rider assignment works reliably

### **Milestone 5: Government Services & Admin Oversight** (Weeks 13-15)
- **Goal**: Central admin functionality, government announcements, professional verification, problem resolution
- **Success Criteria**: 99.9% announcement uptime, admin approval workflows functional, cross-app problem resolution works

### **Milestone 6: Production Readiness** (Weeks 16-18)
- **Goal**: Comprehensive testing, performance optimization, deployment preparation
- **Success Criteria**: All cross-app features work reliably, security validation passes, apps ready for App Store submission

### **Performance Benchmarks:**
- **App Launch**: <2 seconds for all apps
- **Barcode Scanning**: <3 seconds with validation
- **Chat Latency**: <2 seconds message delivery
- **GPS Updates**: Real-time with <10 second intervals
- **SOS Dispatch**: <5 minute rider assignment
- **Data Sync**: <5 seconds cross-app synchronization
- **System Uptime**: 99.9% for government services

---

## Next Steps
- Use `petready_spec.md` to drive code‑generation and project scaffolding.
- Set CI (Fastlane) and TestFlight builds for quick feedback.
- Integrate a real backend when ready (swap APIClient mocks).

## Documentation Map
- Full index: [`Documentation/README.md`](Documentation/README.md)
- Specs & rules now live under `Documentation/Specs` and `Documentation/Guidelines`.
- See [`navigation_plan.md`](Documentation/Specs/navigation_plan.md) for tab structures per app.
- Dev setup/roadmaps live in `Documentation/Development`.

---

**Contact & License**
- Owner: You 🙂  
- License: Private (TBD)
