# PetReady Multi-App Ecosystem — Comprehensive Specification
_Target: Swift 5.5+, SwiftUI, iOS 16+, 4-App Architecture_

---

## 0) Multi-App Product Snapshot

### **Ecosystem Concept**
"หมอพร้อมสำหรับสัตว์เลี้ยง" — A comprehensive 4-app ecosystem serving as both a commercial pet healthcare platform and a government public service for pet welfare and emergency response.

### **Apps in the Ecosystem**
1. **PetReady Owner**: Consumer app for pet owners with complete pet management and service access
2. **PetReady VetPro**: Professional app combining veterinary practice and clinic administration
3. **PetReady Rider**: Transport service app for pet pickups and emergency dispatch
4. **PetReady CentralAdmin**: Government oversight app for system management and problem resolution

### **Core Features Across Apps**
- **Identity**: Barcode/QR pet registration with mock microchip simulation
- **Health**: Digital vaccine books, treatment timelines, government verification
- **Care Access**: Smart vet chat with queuing, clinic discovery, appointment booking
- **Emergency**: SOS dispatch with real-time rider tracking and coordination
- **Government Services**: Public announcements, professional licensing, system oversight
- **Transport**: Full-service pet transport with GPS tracking and payment prototype

### **Technical Architecture**
- **Platform**: 4-app iPhone ecosystem, iOS 16+
- **Language/UI**: Swift 5.5+, SwiftUI (no UIKit/Storyboards)
- **Shared Code Module**: Common models, services, networking across all apps
- **Architecture**: MVVM with SwiftUI Views, ObservableObject ViewModels, cross-app coordination
- **Persistence**: CloudKit/Firebase with offline Core Data caching
- **Real-time Infrastructure**: WebSocket server, push notifications, GPS tracking
- **Authentication**: Phone/email verification with role-based permissions
- **Government Integration**: Official announcement system and professional verification

### **Realistic Integration Elements**
- ✅ **Real Features**: Authentication, cloud database, WebSocket, GPS, push notifications
- 🎭 **Prototype Elements**: Mock microchip scanning, demo payment system, admin-approved verification
- 🏛️ **Government Services**: Public announcements, emergency coordination, professional directory

---

## 1) Multi-App Scope & Features

### **PetReady Owner App** (Consumer App)
**Core Features:**
1. **Homepage with Mixed Layout**: Pet ID card carousel, nearest clinics, government alerts, educational content
2. **Pet Management**: Multi-species profiles with barcode/QR registration, photos, documents
3. **Health Records**: Digital vaccine book, treatment timeline, complete medical history with filters
4. **Smart Chat System**: Vet selection with availability, wait times, 15-min auto-escalation algorithm
5. **Clinic Discovery**: Map-based search with campaigns, promotions, educational content posts
6. **Information Hub**: Government announcements, pet care education, licensed professional directory
7. **SOS Emergency**: Create emergency requests with live rider tracking and ETA updates
8. **User Profile**: Settings, preferences, notification management

### **PetReady VetPro App** (Professional App)
**Dual Mode Interface:**
**Vet Mode:**
1. **Professional Dashboard**: Active patients, appointment schedule, response time metrics
2. **Consultation Queue**: Smart queue management with 15-min response SLA
3. **Patient Records**: Complete access to pet histories, vaccine verification
4. **Telemedicine**: Real-time chat, prescription management, video call handoff
5. **Professional Profile**: Specialization, availability, consultation fees

**Clinic Admin Mode:**
1. **Clinic Management**: Profile, services, pricing, working hours
2. **Campaign Manager**: Create and track marketing campaigns
3. **Content Management**: Educational posts, clinic updates, pet health tips
4. **Staff Management**: Vet profiles, schedules, permissions
5. **Analytics Dashboard**: Patient demographics, visit patterns

### **PetReady Rider App** (Transport Service)
**Core Features:**
1. **Registration System**: Rider signup pending admin approval, document verification
2. **Transport Services**: Emergency SOS, scheduled appointments, grooming/boarding pickups
3. **Smart Dispatch**: Job assignment, GPS navigation, route optimization
4. **Money Pocket**: Payment system for transport fees, tips, service charges
5. **Live Tracking**: Real-time GPS updates, ETA calculations, owner communication
6. **Service History**: Completed jobs, ratings, earnings tracking
7. **Multi-Pet Handling**: Climate-controlled transport, multiple pickup coordination

### **PetReady CentralAdmin App** (Government Oversight)
**System Management:**
1. **Admin Dashboard**: System overview, real-time monitoring, analytics
2. **Pet Registration Feed**: Live Firestore-backed table that lists the most recent owner pet submissions, giving ops instant confirmation that barcode registration succeeded.
2. **User Management**: Approve/reject vet and rider registrations, user oversight
3. **Problem Resolution**: Issue tracking, debugging tools, user communication
4. **Government Announcements**: Public health alerts, emergency coordination
5. **Professional Verification**: Vet credential validation, clinic licensing
6. **System Monitoring**: Performance tracking, uptime monitoring, alert management
7. **Emergency Coordination**: SOS case oversight, disaster response coordination

---

## 2) Multi-App SwiftUI Views & Navigation

### **PetReady Owner App Navigation**
**TabView Structure:**
- **Home Tab**: `HomepageView` with mixed layout (pet carousel, alerts, clinics)
- **Pets Tab**: `PetListView` → `PetDetailView` → `PetEditView`
- **Health Tab**: `HealthHistoryView` → `VaccineBookView` → `TreatmentTimelineView`
- **Clinics Tab**: `ClinicTabView` → `ClinicMapView` → `ClinicDetailView`
- **Chat Tab**: `ChatQueueView` → `ConversationListView` → `ChatRoomView`
- **Information Tab**: `InformationHubView` → `ContentView` → `DirectoryView`
- **Profile Tab**: `SettingsView` → `UserProfileView`

**Key Views & Navigation:**
```
HomepageView (Mixed Layout):
├── GovernmentAlertsView (top banner)
├── PetIDCardCarouselView (scrollable)
├── NearestClinicsView (map + cards)
├── EducationalContentView (feed)
└── CampaignsView (promotional)

PetDetailView:
├── PetInfoView → BarcodeScanView (NavigationLink)
├── MedicalRecordsView → AddRecordView (NavigationLink)
├── DocumentsView → UploadDocumentView (sheet)
├── IssueQRView → ShowQRView (fullScreenCover)
└── EmergencyContactsView

SmartChatFlow:
NewConversationView → VetSelectionView → ChatRoomView
├── VetAvailabilityView (real-time status)
├── WaitTimeEstimateView (15-min algorithm)
├── AutoEscalationView (alternative suggestions)
└── ConversationHistoryView
```

### **PetReady VetPro App Navigation**
**Role-Switch Navigation:**
- **Root**: `RoleSwitchView` (Vet Mode / Clinic Admin Mode)

**Vet Mode:**
```
VetDashboardView:
├── TodayPatientsView → PatientDetailView
├── ConsultationQueueView → ChatRoomView
├── AppointmentScheduleView → AppointmentDetailView
├── ProfessionalProfileView → EditProfileView
└── PerformanceMetricsView

PatientDetailView:
├── MedicalHistoryView → AddRecordView
├── VaccineBookView → VerifyVaccineView
├── ConsultationHistoryView
├── PrescriptionView → NewPrescriptionView
└── VideoCallHandoffView
```

**Clinic Admin Mode:**
```
ClinicAdminView:
├── ClinicProfileView → EditProfileView
├── StaffManagementView → StaffDetailView
├── CampaignManagerView → CreateCampaignView
├── ContentManagementView → CreateContentView
├── AnalyticsDashboardView → DetailedAnalyticsView
└── AppointmentSettingsView
```

### **PetReady Rider App Navigation**
**Main Dashboard Flow:**
```
RiderDashboardView:
├── AvailableJobsView → JobDetailView
├── ActiveJobsView → NavigationView
├── JobHistoryView → JobDetailsView
├── MoneyPocketView → TransactionHistoryView
├── EarningsView → DetailedEarningsView
└── ProfileView → DocumentUploadView

JobAcceptanceFlow:
JobNotificationView → JobDetailView → AcceptJobView
├── RouteOptimizationView
├── NavigationView (GPS tracking)
├── PetHandlingInstructionsView
├── CommunicationWithOwnerView
└── JobCompletionView → RatingView
```

### **PetReady CentralAdmin App Navigation**
**System Oversight Dashboard:**
```
CentralAdminDashboardView:
├── SystemOverviewView → DetailedSystemView
├── UserManagementView → UserApprovalView
├── ProblemResolutionView → IssueDetailView
├── SystemMonitoringView → PerformanceView
├── ContentControlView → CreateAnnouncementView
├── EmergencyCoordinationView → SOSCaseView
└── AnalyticsView → CustomReportsView

UserManagementFlow:
UserApprovalView → VetApplicationView / RiderApplicationView
├── DocumentVerificationView
├── BackgroundCheckView
├── InterviewSchedulingView
├── ApprovalDecisionView
└── NotificationToUserView
```

### **Cross-App Navigation Integration**
**Real-Time Features:**
- **SOS Flow**: Owner App SOS → Rider App Assignment → Admin Monitoring
- **Chat Flow**: Owner Request → Vet Queue → Real-time Communication
- **Government Alerts**: Admin Creation → Cross-App Broadcasting
- **Professional Verification**: Application → Admin Review → Cross-App Recognition

---

## 3) Multi-App Core Data Model (Shared Entities)
All entities include `updatedAt`, `syncedAt`, `isDirty`, `appId`.

### **Shared User Entities**
- **User**: `id`, `userType(enum owner|vet|clinic|admin|rider)`, `displayName`, `phone`, `email`, `profileImageURL`, `verificationStatus`, `createdAt`
- **UserRole**: `id`, `userId`, `role`, `permissions`, `clinicId?`, `approvedBy`, `approvedAt`
- **UserProfile**: `id`, `userId`, `address`, `emergencyContacts`, `preferencesJSON`

### **Pet Management Entities**
- **Pet**: `id`, `ownerId`, `species(enum dog|cat|rabbit|bird|other)`, `breed`, `name`, `sex`, `dob`, `weight`, `photoLocalURL`, `barcodeId`, `microchipCode?`, `status`, `insuranceInfo`
- **Barcode**: `id`, `petId`, `codeText`, `type(enum code128|qr)`, `issuedAt`, `revokedAt?`, `verifiedBy`, `verificationDate`
- **PetDocument**: `id`, `petId`, `documentType`, `fileURL`, `uploadedBy`, `verifiedAt`

### **Healthcare Entities**
- **VaccineRecord**: `id`, `petId`, `clinicId`, `vetId`, `vaccineType`, `brand`, `lot`, `date`, `nextDue`, `verifiedBy`, `qrCodeURL`
- **TreatmentRecord**: `id`, `petId`, `clinicId`, `vetId`, `diagnosis`, `treatment`, `prescription`, `date`, `followUpDate`
- **MedicalDocument**: `id`, `petId`, `documentType`, `fileURL`, `uploadedBy`, `verifiedAt`
- **Reminder**: `id`, `petId`, `userId`, `type(enum vaccine|treatment|appointment|medication)`, `fireDate`, `status`, `recurrenceRule`

### **Clinic & Professional Entities**
- **Clinic**: `id`, `name`, `type(enum veterinary|grooming|boarding|emergency)`, `address`, `lat`, `lng`, `phone`, `email`, `website`, `servicesJSON`, `operatingHours`, `licenseNumber`, `verificationStatus`
- **VetProfile**: `id`, `userId`, `clinicId`, `specializations`, `licenseNumber`, `experience`, `consultationFee`, `availabilityJSON`, `rating`, `consultationCount`
- **ClinicStaff**: `id`, `clinicId`, `userId`, `role`, `permissions`, `isActive`, `joinedAt`
- **Campaign**: `id`, `clinicId`, `title`, `description`, `imageURL`, `startDate`, `endDate`, `targetAudience`, `status`, `metricsJSON`

### **Communication & Chat Entities**
- **Conversation**: `id`, `petId?`, `ownerId`, `vetId`, `status(enum waiting|active|ended|escalated)`, `createdAt`, `endedAt`, `rating`, `escalationCount`
- **Message**: `id`, `conversationId`, `senderId`, `senderType`, `text`, `mediaURL`, `messageType(enum text|image|document|system)`, `readAt`, `createdAt`
- **ChatQueue**: `id`, `conversationId`, `vetId`, `queuePosition`, `estimatedWaitTime`, `escalationTime`, `status`

### **Transport & Rider Entities**
- **TransportJob**: `id`, `requesterId`, `riderId`, `petId`, `jobType(enum emergency|appointment|grooming|boarding)`, `pickupAddress`, `destinationAddress`, `scheduledTime`, `status`, `price`, `distance`
- **RiderProfile**: `id`, `userId`, `vehicleInfo`, `licenseNumber`, `insuranceInfo`, `serviceArea`, `rating`, `totalJobs`, `approvalStatus`
- **JobLocation**: `id`, `jobId`, `latitude`, `longitude`, `timestamp`, `locationType(enum pickup|destination|rider_current)`
- **Transaction**: `id`, `riderId`, `jobId`, `amount`, `type(enum earning|tip|bonus|penalty)`, `status`, `processedAt`

### **Government & Admin Entities**
- **GovernmentAnnouncement**: `id`, `title`, `content`, `type(enum health|emergency|regulatory|education)`, `priority`, `targetAudience`, `publishedBy`, `publishedAt`, `expiresAt`, `status`
- **AdminCase**: `id`, `caseId`, `reportedBy`, `assignedTo`, `type(enum user_issue|system_error|emergency|compliance)`, `status`, `priority`, `description`, `resolution`, `createdAt`, `resolvedAt`
- **SystemMetrics**: `id`, `metricName`, `value`, `timestamp`, `appId`, `metadataJSON`
- **ProfessionalVerification**: `id`, `userId`, `documentType`, `fileURL`, `verifiedBy`, `verificationStatus`, `notes`, `submittedAt`, `verifiedAt`

### **Content & Educational Entities**
- **EducationalContent**: `id`, `clinicId`, `authorId`, `title`, `content`, `contentType(enum article|video|tip)`, `category`, `tags`, `publishedAt`, `status`, `viewCount`
- **ContentApproval**: `id`, `contentId`, `approvedBy`, `status`, `feedback`, `reviewedAt`

---

## 4) Networking API (placeholders)
**Base:** `https://api.petready.app/v1`
- Auth: `POST /auth/login { phone, otp } → { token, user }`
- Pets: `GET/POST/PATCH /pets`, `POST /pets/{id}/register-by-barcode`
- QR: `POST /pets/{id}/qr { scope, ttl } → { qrTokenPNG, payload }`
- Vaccines: `GET /vaccines?petId=`, `POST /vaccines`
- Clinics: `GET /clinics?lat=&lng=&radius=`
- Appointments: `POST /appointments`, `GET /appointments?petId=`, `PATCH /appointments/{id}`
- Chat: `GET /conversations`, `GET /messages?convoId=`, `POST /messages`
- **WebSocket** `/ws/chat` (JWT) — events: `message:new`, `typing`, `read`
- SOS: `POST /sos { petId, triage, location } → { caseId }`, `GET /sos/{caseId}`
- Lost & Found: `POST /lost-report { qrId|petId, message }`

**Security**
- JWT in Keychain; TLS; (optional) SSL pinning; rate limit/backoff.

---

## 5) Services (Swift)
- `AuthService`, `PetService`, `BarcodeService`, `QRService`
- `VaccineService`, `ReminderService` (UNUserNotificationCenter)
- `ClinicService`, `AppointmentService`
- `ChatService` (WebSocket), `UploadService` (multipart)
- `SOSService` (poll/SSE/socket)
- `MapsService` (MapKit overlays + Google Maps deeplink builder)
- `ImageCache` (NSCache + disk)

---

## 6) Barcode & QR
- **Scanner:** `AVCaptureSession` + `AVCaptureMetadataOutput` (supports `.code128`, `.qr`)
- **Validation:** regex + checksum (e.g., Mod97/Base36-CRC)  
  Regex example: `^PET-(DOG|CAT|RAB|OTH)-\d{4}-\d{6}-[0-9A-Z]{2}$`
- **QR generation:** `CIQRCodeGenerator` (server-signed payload; client renders only)

---

## 7) Maps & Google Maps Deeplink
- MapKit shows owner, driver, clinic pins + ETA text overlay.  
- **Open navigation:**  
  `https://www.google.com/maps/dir/?api=1&origin=<lat>,<lng>&destination=<lat>,<lng>&travelmode=driving>`

---

## 8) Notifications
- **Local:** vaccine due, appointment reminders (T-24h/T-2h).  
- **Push:** chat new message, SOS updates, appointment changes.  
- Request on first need; categories for quick actions.

---

## 9) Permissions (Info.plist)
- `NSCameraUsageDescription` (barcode/QR)  
- `NSLocationWhenInUseUsageDescription` (clinics map, SOS viewer)  
- `NSPhotoLibraryAddUsageDescription` (save QR)  
- `NSMicrophoneUsageDescription` (voice hand-off)

---

## 10) Error Handling & Offline
- Scan errors → retry banner + haptic  
- Smart retry with exponential backoff; offline queue for POSTs  
- SOS unavailable → show hotline sheet (configurable)

---

## 11) A11y & i18n
- Dynamic Type; 44pt tap area; VoiceOver on all touch targets and map annotations.  
- `.strings` (TH default, EN secondary).

---

## 12) Security Notes
- Tokens in Keychain; auto-logout on 401  
- QR payloads signed on server; client doesn’t embed PII  
- Purge cached images on logout; ATS strict

---

## 13) Testing
- **Unit:** Services, validators (checksum), mappers  
- **UI (XCUITest):** scan flow, issue QR, book appt, chat send/receive, SOS live map  
- **Snapshot:** key screens (light/dark, TH/EN)  
- **Offline:** vaccine reminder firing without network

---

## 14) Feature Roadmap (Wave-by-Wave, Definition of Done)
### Wave 0 — Foundation
- **Auth & Roles (Owner only for MVP)**, Core entities, CI/CD, logging.  
- **DoD:** register/login works; create/edit Pet; TH/EN switch.

### Wave 1 — Register-by-Barcode
- **Scan Code-128/QR**, regex+checksum, evidence upload.  
- **DoD:** unique barcode claim; audit log; error states covered.

### Wave 2 — Digital Health QR
- Server-signed QR (public/vet), issue/revoke, in-app display.  
- **DoD:** QR shareable, revocable, public page reveals minimal info, vet view gated.

### Wave 3 — Vaccines & Reminders
- Vaccine CRUD, template per species, local notifications.  
- **DoD:** next-due auto-calc; reminders fire on schedule ≥95%.

### Wave 4 — Clinics & Appointments (Basic)
- Map/list search, book/cancel, appointment cards.  
- **DoD:** booking succeeds; reminders T-24h/T-2h delivered.

### Wave 5 — Vet Verification (client hooks)
- Owner flow shows “Verified by Vet” when backend marks; read-only vet notes section.  
- **DoD:** badge rendering + pull-to-refresh state; graceful empty states.

### Wave 6 — Lost & Found via QR
- Public scan → in-app relay to owner; owner receives push.  
- **DoD:** message arrives reliably; owner can reply; PII not exposed.

### Wave 7 — Tele-Chat (MVP)
- WebSocket chat; media upload; quick intake form.  
- **DoD:** send/receive under 2s on LTE; image upload with progress.

### Wave 8 — Tele-Voice (Handoff)
- Secure URL hand-off to in-app Safari; call sheet UX.  
- **DoD:** call connect success ≥97%; consent hint shown.

### Wave 9 — SOS + Dispatch Viewer
- Create SOS; live case screen with driver & clinic pins; ETA updates.  
- **DoD:** first position render < 5s; updates every 5–10s; Google Maps deeplink opens.

### Wave 10 — Payments (Optional Post-MVP)
- Billing for chat/voice/transport; receipts (PDF).  
- **DoD:** success/failure states; receipt share.

### Wave 11 — Advanced Schedules & Growth
- Species-aware vaccine rules; growth chart.  
- **DoD:** correct schedule per species; chart persists offline.

### Wave 12 — Analytics & Compliance
- Screen/feature conversion, PDPA export/erase hooks.  
- **DoD:** dashboard events emitted; data export tested.

---

## 15) Sprint-1 Deliverables (for kickoff)
- Project skeleton (targets + schemes), `Config.plist` (BaseURL/flags), `MainTab.storyboard` with empty tabs.  
- **Wave 1 full**: `BarcodeScanVC`, `PetCreate` (with species picker), `BarcodeService` + validators, Core Data wiring.  
- **Wave 2 partial**: `IssueQRVC` + `ShowQRVC` UI (mock payload), QR generate/render.  
- Unit tests for barcode regex + checksum; XCUITest for scan happy path.

---

## 16) File/Folder Layout (suggested)
```
PetReady/
 ├─ App/ (PetReadyApp.swift, Config, DI)
 ├─ Coordinators/
 ├─ Views/
 │   ├─ Auth/
 │   ├─ MainTab/
 │   ├─ Pet/
 │   ├─ Health/
 │   ├─ Clinic/
 │   ├─ Chat/
 │   ├─ SOS/
 │   └─ Settings/
 ├─ ViewModels/
 ├─ Services/ (AuthService, PetService, BarcodeService, ...)
 ├─ Models/ (Codable DTOs)
 ├─ Persistence/ (CoreData stack + repositories)
 ├─ Networking/ (APIClient, Endpoints, WebSocketClient)
 ├─ Utilities/ (Validators, ImageCache, Formatters, Extensions)
 ├─ Resources/ (Assets.xcassets, Localizable.strings TH/EN)
 └─ Tests/ (Unit + UI)
```

---

## 17) Acceptance Criteria (MVP cut)
- **Scan & Register:** scan completes < 3s; invalid code gets actionable error; duplicate barcode blocked.  
- **QR:** issue in ≤3 taps; revoke reflects immediately; sharing uses iOS share sheet.  
- **Vaccines:** next due auto-filled; reminders appear at T-7 at correct local time.  
- **Clinics:** map pins within 5km; booking confirms; conflict handled.  
- **Chat:** send text/image; typing & read receipts; background push arrives.  
- **SOS:** map shows 3 markers (you/driver/clinic) and ETA updates every ≤10s; Google Maps deeplink works.

---

# 👉 CODEGEN PROMPT (Paste into your AI/codegen tool)

**Goal:** Generate an iOS app scaffold named **PetReady** (iPhone-only) using **Swift 5.5+**, **SwiftUI**, **iOS 16+**, following the spec below. Produce compilable code, SwiftUI Views, coordinators, services with stubs, Core Data model, and sample mocks.

## Requirements
1. **Targets & Config**
   - Single target `PetReady` (Debug/Release) + `PetReadyStaging` (separate bundle id, build config).
   - `Config.plist` per scheme: `API_BASE_URL`, feature flags (`ENABLE_CHAT`, `ENABLE_SOS`).

2. **SwiftUI Views & Navigation**
   - Create SwiftUI Views: `AuthView`, `MainTabView`, `PetListView`, `HealthView`, `ClinicView`, `ChatView`, `SOSView`, `SettingsView`.
   - Add SwiftUI Views exactly as:
     `PetListView`, `PetDetailView`, `PetEditView`, `BarcodeScanView`, `IssueQRView`, `ShowQRView`,
     `VaccineTimelineView`, `AddVaccineView`, `ReminderSettingsView`,
     `ClinicMapView`, `ClinicListView`, `ClinicDetailView`, `ApptBookingView`, `ApptDetailView`,
     `ConversationListView`, `ChatRoomView`, `CallSheetView`,
     `SOSStartView`, `SOSLiveView`,
     `SettingsView`, `ProfileView`.
   - Add minimal UI (Text/Button/List/Map) enough to compile and navigate with NavigationStack/TabView.

3. **Coordinators**
   - `AppCoordinator` (launch → auth/main tab), `AuthCoordinator`, `MainTabCoordinator`, feature coordinators.

4. **Models & Core Data**
   - Add Core Data model with entities described in Section 3 (User, Pet, Barcode, VaccineRecord, Reminder, Clinic, Appointment, Conversation, Message, SOSCase).  
   - Implement `CoreDataStack` and simple `Repository` stubs (e.g., `PetRepository` with CRUD).

5. **Services (stubs with protocols)**
   - `AuthService`, `PetService`, `BarcodeService` (regex + checksum util), `QRService` (generate QR via CoreImage),  
     `VaccineService`, `ReminderService`, `ClinicService`, `AppointmentService`,  
     `ChatService` (WebSocket skeleton with connect/send/receive handlers),  
     `SOSService` (polling stub), `MapsService` (Google Maps deeplink builder), `ImageCache`.
   - `APIClient` with URLSession + simple `Endpoint` enum; mock implementation for Staging.

6. **Barcode & QR**
   - Implement `BarcodeScanView` using AVFoundation to detect **Code-128 & QR**; haptic on success; validate via regex and checksum.
   - `QRService` to generate UIImage QR from server-signed payload (mock payload for now).

7. **Map & Deeplink**
   - `ClinicMapView` and `SOSLiveView` use MapKit with mock pins; provide function to open Google Maps deeplink:
     ```swift
     func openGoogleMaps(origin: CLLocationCoordinate2D?, destination: CLLocationCoordinate2D)
     ```

8. **Notifications**
   - `ReminderService` schedules local notifications for vaccine due; request permission lazily.

9. **Navigation**
   - Wire minimal NavigationLinks and sheet/fullScreenCover presentations listed in Section 2; ensure TabView root with five tabs.

10. **Localization & A11y**
   - Add `Localizable.strings` for TH and EN with sample strings; set accessibility labels on buttons.

11. **Tests**
   - Unit tests for barcode regex + checksum; basic test for `APIClient` mock; one XCUITest to scan (mock camera feed allowed) or navigate to `BarcodeScanView`.

12. **Placeholders**
   - Network calls return mock JSON; no real backend needed.
   - Provide stubbed data lists for Pets, Clinics, Conversations.

13. **Build**
   - Ensure the project compiles and runs to a navigable shell: can add a Pet, open scanner, issue a QR (mock), see vaccine timeline (empty state), open clinic map, open chat list (mock), open SOS live (mock pins), change language.

**Deliverables:**
- Xcode project with source files and SwiftUI Views.
- Clear `README.md` describing schemes, configs, and where mocks are.
- Minimal but clean SwiftUI UI and dark mode compatible.

**Follow the spec sections above** for naming and structure. Keep code idiomatic Swift (SwiftUI only). Use MVVM + lightweight Coordinators, and keep Services protocol-first for testability.
