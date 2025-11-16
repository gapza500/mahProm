# PetReady Project Rules

These rules consolidate the constraints and expectations defined in `README.md` and `petready_spec.md`. They govern how the PetReady multi-app ecosystem must be designed, implemented, and validated.

## 1. Platform & Scope
- **Target**: 4-app ecosystem for iPhone-only, iOS 16+, Swift 5.5+, SwiftUI (no UIKit/Storyboards).
  - **PetReady Owner**: Main consumer app for pet owners
  - **PetReady VetPro**: Combined veterinary and clinic management app
  - **PetReady Rider**: Transport and dispatch service app
  - **PetReady CentralAdmin**: Government/admin oversight and problem resolution app
- **Core scope**: barcode-based pet registration, multi-species profiles, digital health QR, vaccines + reminders, clinic map & appointments, tele-chat with smart queuing, SOS dispatch with rider tracking, government service announcements, and central admin oversight.
- **Deliverable**: 4 compilable Xcode projects with shared code module, staging schemes, and backend integration ready for production deployment.

## 2. Architecture & Project Structure
- **Multi-App Architecture**: Each app uses MVVM with SwiftUI Views and ObservableObject ViewModels, coordinated by lightweight Navigation Coordinators.
- **Shared Code Module**: Common models, services, utilities, and networking components shared across all 4 apps.
- **Individual App Structure**: Each app maintains Services (protocol-first), Repositories, Core Data stack, Networking layer, Utilities, Resources, and Tests folders.
- **Dependency Injection**: Through @EnvironmentObject and @StateObject; Services configurable for mock vs live deployment.
- **Feature Flags**: Stored in `Config.plist` (per scheme) for Chat/SOS/Government Alerts toggles.
- **Role-Based Access**: Central Admin app has system-wide oversight capabilities; Vet Pro app supports dual Vet/Clinic Admin modes.

### Multi-App Folder Structure:
```
PetReady-Ecosystem/
├── PetReady-Owner/              # Consumer app
├── PetReady-VetPro/             # Veterinary professional app
├── PetReady-Rider/              # Transport service app
├── PetReady-CentralAdmin/       # Government oversight app
├── SharedCode/                  # Common models, services, utilities
├── Backend/                     # Cloud database, APIs, WebSocket
└── Documentation/               # Specs, architecture docs
```

## 3. SwiftUI Views & Navigation

### PetReady Owner App
- **Required Views**: `AuthView`, `HomepageView`, `PetListView`, `PetDetailView`, `HealthHistoryView`, `ClinicTabView`, `ChatQueueView`, `InformationHubView`, `SettingsView`.
- **Root Flow**: `PetReadyApp` -> Auth flow or `HomepageView` with mixed layout.
- **Navigation Structure**: TabView with Home, Pets, Health, Clinics, Chat, Information tabs.

### PetReady VetPro App
- **Required Views**: `RoleSwitchView`, `VetDashboardView`, `ClinicAdminView`, `PatientListView`, `ConsultationQueueView`, `ContentManagementView`.
- **Dual Mode Interface**: Switch between Vet and Clinic Admin functionality.
- **Root Flow**: `VetProApp` -> Role selection or auto-switch based on user permissions.

### PetReady Rider App
- **Required Views**: `RiderAuthView`, `TransportDashboardView`, `JobListView`, `NavigationView`, `MoneyPocketView`, `ProfileView`.
- **Root Flow**: `RiderApp` -> Registration (pending approval) or Dashboard.

### PetReady CentralAdmin App
- **Required Views**: `AdminDashboardView`, `UserManagementView`, `ProblemResolutionView`, `SystemMonitoringView`, `ContentControlView`, `AnalyticsView`.
- **Root Flow**: `CentralAdminApp` -> System overview dashboard with full administrative access.

## 4. Data & Services Rules
- **Shared Data Models**: Core Data entities (User, Pet, Barcode, VaccineRecord, Reminder, Clinic, Appointment, Conversation, Message, SOSCase, RiderJob, AdminCase) must include `updatedAt`, `syncedAt`, `isDirty`.
- **Multi-Role Access**: Central Admin has read/write access to all data; Vet Pro has patient access; Owner has pet data access; Rider has transport job access.
- **Persistence Access**: Via repositories; Services wrap business logic (Auth, Pet, Barcode, QR, Vaccine, Reminder, Clinic, Appointment, Chat, SOS, Rider, Admin, Maps, ImageCache).
- **Barcode Service**: Enforces Code-128/QR regex `^PET-(DOG|CAT|RAB|OTH)-\d{4}-\d{6}-[0-9A-Z]{2}$` with checksum validation.
- **QR Service**: Produces signed-payload images with government verification capabilities.
- **Smart Chat Queue**: 15-minute auto-escalation algorithm with alternative vet suggestions.
- **Rider Dispatch**: Real-time job assignment and GPS tracking integration.
- **Government Integration**: Public announcement system and emergency response coordination.
- **Networking**: URLSession + WebSocket for real-time features, CloudKit for data synchronization, Google Maps deeplink helper.

### App-Specific Services:
- **Owner App**: PetService, ChatQueueService, InformationService, AppointmentService
- **VetPro App**: ConsultationService, PatientService, ClinicService, ContentService
- **Rider App**: TransportService, NavigationService, MoneyPocketService
- **Central Admin**: AdminService, UserManagementService, ProblemResolutionService, SystemMonitorService

## 5. Feature Delivery Rules (Definitions of Done)
- **Phase-Based Development**: Foundation → Core Features → Communication → Transport → Government Services → Advanced Features.
- **Multi-App Coordination**: Features must work across all 4 apps with real-time synchronization.
- **Realistic Integration**: Real authentication, cloud database, WebSocket communication, GPS tracking, push notifications.
- **Prototype Elements**: Barcode scanning (mock microchip), demo payment system, admin-approved professional verification.
- **Performance Metrics**: Scan <3s, Chat latency <2s, SOS updates ≤10s, GPS accuracy <15m, app launch <2s.
- **Government Service Standards**: Public announcements must be reliable, emergency response must be robust, data privacy must be maintained.
- **Testing Requirements**: Each app must have unit tests, integration tests for cross-app features, and real-world scenario testing.

### Cross-App Feature Requirements:
- **Pet Registration**: Must work from Owner App and be visible in Vet Pro App
- **Chat System**: Real-time between Owner and Vet Pro with queue management
- **SOS Dispatch**: Owner App request → Rider App assignment → Central Admin monitoring
- **Government Announcements**: Central Admin creation → Owner App display → Vet Pro acknowledgment
- **User Management**: Central Admin approval flow for Vet Pro and Rider registrations

## 6. Testing & Quality
- **Multi-App Testing**: Each app requires comprehensive unit tests, UI tests, and cross-app integration tests.
- **Real-Time Features**: WebSocket communication, GPS tracking, and push notifications must be tested under various network conditions.
- **Performance Testing**: Validate app launch times, chat latency (<2s), GPS accuracy (<15m), and SOS response times.
- **Security Testing**: Authentication, role-based access control, and data encryption must be validated.
- **Cross-Platform Integration**: Test data synchronization between all 4 apps and backend services.
- **Government Service Reliability**: Emergency announcements and SOS dispatch must have 99.9% uptime testing.
- **User Experience Testing**: Accessibility (VoiceOver, Dynamic Type), localization (TH/EN), and offline functionality.

## 7. Build & Run Expectations
- **Multi-App Build System**: Provide build instructions for all 4 apps with shared code module integration.
- **Staging Schemes**: Each app should have Debug/Release and Staging schemes with configurable backend endpoints.
- **Compilation**: All SwiftUI Views must compile without runtime warnings, Core Data stack must initialize across all apps.
- **Real Backend Integration**: Configure for actual cloud database, WebSocket server, and push notification services.
- **Government Service Setup**: Configure announcement broadcasting and emergency response systems.
- **Cross-App Features**: Test real-time synchronization between apps during development.
- **Localization**: Support TH/EN across all apps with consistent terminology.
- **Dark Mode**: All apps must support system appearance settings.

## 8. Contribution Process
- **Multi-App Considerations**: Any contribution must consider cross-app compatibility and impact on the entire ecosystem.
- **Code Quality**: Keep code idiomatic Swift 5.5+, follow multi-app folder conventions, use SwiftUI exclusively.
- **Shared Module Updates**: Changes to shared code must be tested across all 4 apps for compatibility.
- **Real Integration**: Maintain both mock and real backend configurations for development flexibility.
- **Government Service Standards**: Ensure any public-facing content meets government service reliability and security standards.
- **Documentation**: Update all relevant documentation when implementing cross-app features.
- **Testing**: Cross-app integration tests must pass before merging any shared code changes.

Following these rules keeps the entire PetReady ecosystem aligned with the multi-app architecture and ensures all milestones maintain government service quality standards.
