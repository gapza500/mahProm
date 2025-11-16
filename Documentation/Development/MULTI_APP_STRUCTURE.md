# PetReady Multi-App Folder Structure Documentation

## Complete Ecosystem Architecture

This document outlines the comprehensive folder structure for the PetReady 4-app ecosystem, including shared code modules, backend services, and development infrastructure.

## Root Directory Structure

```
PetReady-Ecosystem/
├── README.md                         # Main ecosystem documentation
├── .gitignore                        # Git ignore rules for all apps
├── Package.swift                     # Swift Package Manager for shared module
├── PetReady.xcworkspace             # Xcode workspace containing all apps
├── Scripts/                          # Build and deployment scripts
│   ├── build-all.sh                 # Build all apps
│   ├── test-integration.sh          # Cross-app integration tests
│   ├── deploy-staging.sh            # Deploy to staging environment
│   └── setup-development.sh         # Initial development setup
├── Documentation/                    # Comprehensive documentation
│   ├── API/                         # API documentation
│   ├── Architecture/                # Architecture diagrams and decisions
│   ├── Deployment/                  # Deployment guides and procedures
│   ├── UserGuides/                  # End-user documentation
│   └── Development/                 # Development setup and guides
├── Tools/                           # Development and deployment tools
│   ├── code-generator/              # Code generation tools
│   ├── testing-frameworks/          # Custom testing utilities
│   └── deployment-automation/       # CI/CD pipeline configurations
└── Config/                          # Configuration files
    ├── staging.yml                  # Staging environment configuration
    ├── production.yml               # Production environment configuration
    └── development.yml              # Development environment configuration
```

## App-Specific Structures

### PetReady-Owner/ (Consumer App)

```
PetReady-Owner/
├── PetReadyOwner.xcodeproj
├── PetReadyOwner/
│   ├── App/
│   │   ├── PetReadyOwnerApp.swift     # Main app entry point
│   │   ├── ContentView.swift          # Root view
│   │   └── Info.plist                # App configuration
│   ├── Views/                         # SwiftUI Views
│   │   ├── Auth/
│   │   │   ├── AuthView.swift
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterView.swift
│   │   │   └── PhoneVerificationView.swift
│   │   ├── Homepage/
│   │   │   ├── HomepageView.swift     # Mixed layout main screen
│   │   │   ├── GovernmentAlertsView.swift
│   │   │   ├── PetIDCardCarouselView.swift
│   │   │   ├── NearestClinicsView.swift
│   │   │   ├── EducationalContentView.swift
│   │   │   └── CampaignsView.swift
│   │   ├── Pet/
│   │   │   ├── PetListView.swift
│   │   │   ├── PetDetailView.swift
│   │   │   ├── PetEditView.swift
│   │   │   ├── PetPhotoView.swift
│   │   │   └── AddPetView.swift
│   │   ├── Health/
│   │   │   ├── HealthHistoryView.swift
│   │   │   ├── VaccineBookView.swift
│   │   │   ├── TreatmentTimelineView.swift
│   │   │   ├── AddVaccineView.swift
│   │   │   ├── AddTreatmentView.swift
│   │   │   └── MedicalDocumentsView.swift
│   │   ├── Clinic/
│   │   │   ├── ClinicTabView.swift
│   │   │   ├── ClinicMapView.swift
│   │   │   ├── ClinicListView.swift
│   │   │   ├── ClinicDetailView.swift
│   │   │   ├── CampaignDetailView.swift
│   │   │   └── BookAppointmentView.swift
│   │   ├── Chat/
│   │   │   ├── ChatQueueView.swift
│   │   │   ├── ConversationListView.swift
│   │   │   ├── ChatRoomView.swift
│   │   │   ├── NewConversationView.swift
│   │   │   ├── VetSelectionView.swift
│   │   │   ├── WaitingQueueView.swift
│   │   │   └── ChatHistoryView.swift
│   │   ├── Information/
│   │   │   ├── InformationHubView.swift
│   │   │   ├── GovernmentAnnouncementsView.swift
│   │   │   ├── EducationalContentView.swift
│   │   │   ├── ProfessionalDirectoryView.swift
│   │   │   ├── HealthTipsView.swift
│   │   │   └── EmergencyResourcesView.swift
│   │   ├── SOS/
│   │   │   ├── SOSRequestView.swift
│   │   │   ├── SOSLiveView.swift
│   │   │   ├── EmergencyContactsView.swift
│   │   │   └── RiderTrackingView.swift
│   │   ├── Profile/
│   │   │   ├── SettingsView.swift
│   │   │   ├── UserProfileView.swift
│   │   │   ├── NotificationSettingsView.swift
│   │   │   ├── PrivacySettingsView.swift
│   │   │   └── HelpSupportView.swift
│   │   └── Components/                # Reusable UI components
│   │       ├── PetCardView.swift
│   │       ├── ClinicCardView.swift
│   │       ├── MessageBubbleView.swift
│   │       ├── AlertBannerView.swift
│   │       ├── LoadingIndicatorView.swift
│   │       └── QRCodeView.swift
│   ├── ViewModels/                    # ObservableObject ViewModels
│   │   ├── AuthViewModel.swift
│   │   ├── HomepageViewModel.swift
│   │   ├── PetListViewModel.swift
│   │   ├── PetDetailViewModel.swift
│   │   ├── HealthHistoryViewModel.swift
│   │   ├── ClinicTabViewModel.swift
│   │   ├── ChatQueueViewModel.swift
│   │   ├── InformationHubViewModel.swift
│   │   ├── SOSViewModel.swift
│   │   └── SettingsViewModel.swift
│   ├── Services/                      # Owner-specific services
│   │   ├── OwnerAuthService.swift
│   │   ├── PetService.swift
│   │   ├── ChatQueueService.swift
│   │   ├── InformationService.swift
│   │   ├── AppointmentService.swift
│   │   └── SOSService.swift
│   ├── Resources/                     # App-specific resources
│   │   ├── Assets.xcassets
│   │   ├── Localizable.strings
│   │   ├── Localizable.strings (TH)
│   │   ├── Colors.xcassets
│   │   └── Fonts/
│   └── Tests/
│       ├── UnitTests/
│       └── UITests/
```

### PetReady-VetPro/ (Professional App)

```
PetReady-VetPro/
├── PetReadyVetPro.xcodeproj
├── PetReadyVetPro/
│   ├── App/
│   │   ├── PetReadyVetProApp.swift
│   │   ├── ContentView.swift
│   │   └── Info.plist
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── VetAuthView.swift
│   │   │   ├── ProfessionalRegistrationView.swift
│   │   │   ├── DocumentUploadView.swift
│   │   │   └── ApplicationStatusView.swift
│   │   ├── RoleSwitch/
│   │   │   ├── RoleSwitchView.swift     # Vet Mode / Clinic Admin Mode
│   │   │   ├── VetDashboardView.swift
│   │   │   └── ClinicAdminView.swift
│   │   ├── VetMode/
│   │   │   ├── ProfessionalDashboardView.swift
│   │   │   ├── TodayPatientsView.swift
│   │   │   ├── ConsultationQueueView.swift
│   │   │   ├── AppointmentScheduleView.swift
│   │   │   ├── ProfessionalProfileView.swift
│   │   │   ├── PerformanceMetricsView.swift
│   │   │   ├── PatientDetailView.swift
│   │   │   ├── MedicalHistoryView.swift
│   │   │   ├── VaccineBookView.swift
│   │   │   ├── PrescriptionView.swift
│   │   │   ├── ConsultationHistoryView.swift
│   │   │   └── VideoCallHandoffView.swift
│   │   ├── ClinicAdminMode/
│   │   │   ├── ClinicManagementView.swift
│   │   │   ├── ClinicProfileView.swift
│   │   │   ├── StaffManagementView.swift
│   │   │   ├── CampaignManagerView.swift
│   │   │   ├── ContentManagementView.swift
│   │   │   ├── AnalyticsDashboardView.swift
│   │   │   ├── ServiceSettingsView.swift
│   │   │   └── AppointmentSettingsView.swift
│   │   ├── Shared/
│   │   │   ├── PatientSearchView.swift
│   │   │   ├── CalendarView.swift
│   │   │   ├── ChartViews.swift
│   │   │   └── ReportViews.swift
│   │   └── Components/
│   │       ├── PatientCardView.swift
│   │       ├── AppointmentCardView.swift
│   │       ├── StaffCardView.swift
│   │       ├── CampaignCardView.swift
│   │       └── MetricCardView.swift
│   ├── ViewModels/
│   │   ├── VetAuthViewModel.swift
│   │   ├── RoleSwitchViewModel.swift
│   │   ├── VetDashboardViewModel.swift
│   │   ├── ConsultationQueueViewModel.swift
│   │   ├── ClinicAdminViewModel.swift
│   │   ├── PatientManagementViewModel.swift
│   │   └── AnalyticsViewModel.swift
│   ├── Services/
│   │   ├── VetAuthService.swift
│   │   ├── ConsultationService.swift
│   │   ├── PatientService.swift
│   │   ├── ClinicService.swift
│   │   ├── ContentService.swift
│   │   └── ProfessionalVerificationService.swift
│   ├── Resources/
│   └── Tests/
```

### PetReady-Rider/ (Transport App)

```
PetReady-Rider/
├── PetReadyRider.xcodeproj
├── PetReadyRider/
│   ├── App/
│   │   ├── PetReadyRiderApp.swift
│   │   ├── ContentView.swift
│   │   └── Info.plist
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── RiderAuthView.swift
│   │   │   ├── RiderRegistrationView.swift
│   │   │   ├── DocumentVerificationView.swift
│   │   │   ├── VehicleRegistrationView.swift
│   │   │   └── RegistrationStatusView.swift
│   │   ├── Dashboard/
│   │   │   ├── RiderDashboardView.swift
│   │   │   ├── AvailableJobsView.swift
│   │   │   ├── ActiveJobsView.swift
│   │   │   ├── JobHistoryView.swift
│   │   │   ├── EarningsOverviewView.swift
│   │   │   └── PerformanceMetricsView.swift
│   │   ├── Jobs/
│   │   │   ├── JobDetailView.swift
│   │   │   ├── JobAcceptanceView.swift
│   │   │   ├── NavigationView.swift
│   │   │   ├── RouteOptimizationView.swift
│   │   │   ├── PetHandlingInstructionsView.swift
│   │   │   ├── CommunicationWithOwnerView.swift
│   │   │   ├── JobCompletionView.swift
│   │   │   └── RatingView.swift
│   │   ├── MoneyPocket/
│   │   │   ├── MoneyPocketView.swift
│   │   │   ├── TransactionHistoryView.swift
│   │   │   ├── EarningsDetailView.swift
│   │   │   ├── PayoutSettingsView.swift
│   │   │   └── PaymentMethodsView.swift
│   │   ├── Profile/
│   │   │   ├── RiderProfileView.swift
│   │   │   ├── DocumentUploadView.swift
│   │   │   ├── VehicleInfoView.swift
│   │   │   ├── ServiceAreaView.swift
│   │   │   ├── AvailabilitySettingsView.swift
│   │   │   └── RatingReviewsView.swift
│   │   ├── Map/
│   │   │   ├── MapView.swift
│   │   │   ├── RouteTrackingView.swift
│   │   │   ├── LocationSharingView.swift
│   │   │   └── ETAView.swift
│   │   └── Components/
│   │       ├── JobCardView.swift
│   │       ├── TransactionCardView.swift
│   │       ├── MapAnnotationView.swift
│   │       ├── RouteLineView.swift
│   │       └── EarningsChartView.swift
│   ├── ViewModels/
│   │   ├── RiderAuthViewModel.swift
│   │   ├── DashboardViewModel.swift
│   │   ├── JobManagementViewModel.swift
│   │   ├── NavigationViewModel.swift
│   │   ├── MoneyPocketViewModel.swift
│   │   └── ProfileViewModel.swift
│   ├── Services/
│   │   ├── RiderAuthService.swift
│   │   ├── TransportService.swift
│   │   ├── NavigationService.swift
│   │   ├── MoneyPocketService.swift
│   │   ├── GPSTrackingService.swift
│   │   └── RouteOptimizationService.swift
│   ├── Resources/
│   └── Tests/
```

### PetReady-CentralAdmin/ (Government Oversight App)

```
PetReady-CentralAdmin/
├── PetReadyCentralAdmin.xcodeproj
├── PetReadyCentralAdmin/
│   ├── App/
│   │   ├── PetReadyCentralAdminApp.swift
│   │   ├── ContentView.swift
│   │   └── Info.plist
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── AdminAuthView.swift
│   │   │   ├── GovernmentLoginView.swift
│   │   │   └── SecurityVerificationView.swift
│   │   ├── Dashboard/
│   │   │   ├── AdminDashboardView.swift
│   │   │   ├── SystemOverviewView.swift
│   │   │   ├── RealTimeMetricsView.swift
│   │   │   ├── AlertCenterView.swift
│   │   │   ├── QuickActionsView.swift
│   │   │   └── SystemHealthView.swift
│   │   ├── UserManagement/
│   │   │   ├── UserManagementView.swift
│   │   │   ├── UserApprovalView.swift
│   │   │   ├── VetApplicationView.swift
│   │   │   ├── RiderApplicationView.swift
│   │   │   ├── UserDetailView.swift
│   │   │   ├── DocumentVerificationView.swift
│   │   │   ├── BackgroundCheckView.swift
│   │   │   └── UserSuspensionView.swift
│   │   ├── ProblemResolution/
│   │   │   ├── ProblemResolutionView.swift
│   │   │   ├── IssueTrackingView.swift
│   │   │   ├── IssueDetailView.swift
│   │   │   ├── DebuggingToolsView.swift
│   │   │   ├── UserCommunicationView.swift
│   │   │   ├── SystemDiagnosticsView.swift
│   │   │   └── ResolutionWorkflowView.swift
│   │   ├── ContentControl/
│   │   │   ├── GovernmentAnnouncementsView.swift
│   │   │   ├── CreateAnnouncementView.swift
│   │   │   ├── EmergencyAlertsView.swift
│   │   │   ├── ContentModerationView.swift
│   │   │   ├── PublicHealthAlertsView.swift
│   │   │   └── RegulatoryUpdatesView.swift
│   │   ├── SystemMonitoring/
│   │   │   ├── SystemMonitoringView.swift
│   │   │   ├── PerformanceMetricsView.swift
│   │   │   ├── UptimeMonitoringView.swift
│   │   │   ├── AnalyticsView.swift
│   │   │   ├── LogAnalysisView.swift
│   │   │   ├── SecurityMonitoringView.swift
│   │   │   └── CustomReportsView.swift
│   │   ├── EmergencyCoordination/
│   │   │   ├── EmergencyCoordinationView.swift
│   │   │   ├── SOSCaseManagementView.swift
│   │   │   ├── DisasterResponseView.swift
│   │   │   ├── ResourceAllocationView.swift
│   │   │   └── CrisisCommunicationView.swift
│   │   ├── ProfessionalVerification/
│   │   │   ├── ProfessionalVerificationView.swift
│   │   │   ├── VetCredentialValidationView.swift
│   │   │   ├── ClinicLicensingView.swift
│   │   │   ├── RiderBackgroundCheckView.swift
│   │   │   └── ComplianceMonitoringView.swift
│   │   └── Components/
│   │       ├── MetricCardView.swift
│   │       ├── AlertCardView.swift
│   │       ├── UserCardView.swift
│   │       ├── SystemStatusView.swift
│   │       ├── ChartViews.swift
│   │       └── DataTableView.swift
│   ├── ViewModels/
│   │   ├── AdminAuthViewModel.swift
│   │   ├── DashboardViewModel.swift
│   │   ├── UserManagementViewModel.swift
│   │   ├── ProblemResolutionViewModel.swift
│   │   ├── ContentControlViewModel.swift
│   │   ├── SystemMonitoringViewModel.swift
│   │   ├── EmergencyCoordinationViewModel.swift
│   │   └── ProfessionalVerificationViewModel.swift
│   ├── Services/
│   │   ├── AdminAuthService.swift
│   │   ├── UserManagementService.swift
│   │   ├── ProblemResolutionService.swift
│   │   ├── SystemMonitorService.swift
│   │   ├── ContentControlService.swift
│   │   ├── EmergencyCoordinationService.swift
│   │   ├── ProfessionalVerificationService.swift
│   │   └── AnalyticsService.swift
│   ├── Resources/
│   └── Tests/
```

## Shared Code Module

```
SharedCode/
├── Package.swift                     # Swift Package definition
├── Sources/
│   ├── PetReadyShared/              # Main shared module
│   │   ├── Models/                   # Shared data models
│   │   │   ├── UserModels.swift
│   │   │   ├── PetModels.swift
│   │   │   ├── ClinicModels.swift
│   │   │   ├── MessageModels.swift
│   │   │   ├── TransportModels.swift
│   │   │   ├── AdminModels.swift
│   │   │   ├── GovernmentModels.swift
│   │   │   └── CoreDataModels.swift
│   │   ├── Services/                 # Shared services
│   │   │   ├── NetworkService.swift
│   │   │   ├── AuthService.swift
│   │   │   ├── WebSocketService.swift
│   │   │   ├── NotificationService.swift
│   │   │   ├── GPSService.swift
│   │   │   ├── CloudSyncService.swift
│   │   │   └── ValidationService.swift
│   │   ├── Utilities/                # Common utilities
│   │   │   ├── Extensions/
│   │   │   ├── Formatters/
│   │   │   ├── Validators/
│   │   │   ├── Constants.swift
│   │   │   ├── Enums.swift
│   │   │   └── Helpers.swift
│   │   ├── Networking/               # Shared networking
│   │   │   ├── APIClient.swift
│   │   │   ├── Endpoints.swift
│   │   │   ├── WebSocketClient.swift
│   │   │   └── NetworkMonitor.swift
│   │   └── Resources/                # Shared resources
│   │       ├── Colors.xcassets
│   │       ├── Fonts/
│   │       ├── Images.xcassets
│   │       ├── Localizable.strings
│   │       └── Localizable.strings (TH)
│   └── PetReadySharedTesting/        # Shared testing utilities
│       ├── MockServices.swift
│       ├── TestModels.swift
│       ├── TestDataGenerator.swift
│       └── IntegrationTestHelpers.swift
└── Tests/
    ├── PetReadySharedTests/
    └── PetReadySharedTestingTests/
```

## Backend Services

```
Backend/
├── package.json                      # Node.js dependencies
├── server.js                        # Main server entry point
├── src/
│   ├── API/                         # REST API endpoints
│   │   ├── auth/
│   │   │   ├── login.js
│   │   │   ├── register.js
│   │   │   ├── verification.js
│   │   │   └── roles.js
│   │   ├── pets/
│   │   │   ├── pets.js
│   │   │   ├── medical-records.js
│   │   │   ├── vaccinations.js
│   │   │   └── documents.js
│   │   ├── clinics/
│   │   │   ├── clinics.js
│   │   │   ├── appointments.js
│   │   │   ├── campaigns.js
│   │   │   └── content.js
│   │   ├── chat/
│   │   │   ├── conversations.js
│   │   │   ├── messages.js
│   │   │   ├── queue.js
│   │   │   └── escalations.js
│   │   ├── transport/
│   │   │   ├── jobs.js
│   │   │   ├── riders.js
│   │   │   ├── dispatch.js
│   │   │   └── payments.js
│   │   ├── admin/
│   │   │   ├── users.js
│   │   │   ├── announcements.js
│   │   │   ├── monitoring.js
│   │   │   └── analytics.js
│   │   └── websocket/
│   │       ├── chat-events.js
│   │       ├── location-updates.js
│   │       ├── notifications.js
│   │       └── emergency-events.js
│   ├── Database/                    # Database configurations
│   │   ├── models/
│   │   ├── migrations/
│   │   ├── seeds/
│   │   └── connections/
│   ├── WebSocket/                    # WebSocket server
│   │   ├── server.js
│   │   ├── handlers/
│   │   ├── events/
│   │   └── middleware/
│   ├── Services/                     # Business logic services
│   │   ├── AuthService.js
│   │   ├── ChatService.js
│   │   ├── NotificationService.js
│   │   ├── GPSService.js
│   │   ├── PaymentService.js
│   │   ├── FileUploadService.js
│   │   └── AnalyticsService.js
│   ├── Middleware/                   # Express middleware
│   │   ├── auth.js
│   │   ├── validation.js
│   │   ├── rateLimiting.js
│   │   ├── logging.js
│   │   ├── errorHandling.js
│   │   └── security.js
│   ├── Utils/                        # Utility functions
│   │   ├── helpers.js
│   │   ├── validators.js
│   │   ├── formatters.js
│   │   ├── constants.js
│   │   └── config.js
│   └── Cloud/                       # Cloud service integrations
│       ├── aws/
│       ├── firebase/
│       ├── cloudkit/
│       └── push-notifications/
├── config/                          # Environment configurations
│   ├── development.json
│   ├── staging.json
│   ├── production.json
│   └── test.json
├── tests/                           # Backend tests
│   ├── unit/
│   ├── integration/
│   └── load/
└── deployment/                      # Deployment configurations
    ├── docker/
    ├── kubernetes/
    ├── terraform/
    └── scripts/
```

## Development Tools and Configuration

### Configuration Files

```
Config/
├── development.yml                 # Development environment settings
│   ├── database:
│   ├── api_endpoints:
│   ├── websocket:
│   ├── authentication:
│   └── features:
├── staging.yml                     # Staging environment settings
├── production.yml                  # Production environment settings
├── testing.yml                     # Testing environment settings
└── feature-flags.yml              # Feature flags for all apps
```

### Build and Deployment Scripts

```
Scripts/
├── build-all.sh                    # Build all 4 apps
├── test-all.sh                     # Run tests for all apps
├── deploy-all.sh                   # Deploy all apps
├── setup-development.sh            # Initial development setup
├── integration-tests.sh            # Cross-app integration tests
├── performance-tests.sh            # Performance and load tests
├── security-tests.sh               # Security vulnerability tests
└── backup-data.sh                  # Data backup procedures
```

## Documentation Structure

```
Documentation/
├── README.md                       # Main documentation index
├── API/                           # API documentation
│   ├── authentication.md
│   ├── pets.md
│   ├── clinics.md
│   ├── chat.md
│   ├── transport.md
│   ├── admin.md
│   └── websocket.md
├── Architecture/                   # Architecture documentation
│   ├── multi-app-design.md
│   ├── data-flow.md
│   ├── security.md
│   ├── scalability.md
│   └── decision-records/
├── Deployment/                     # Deployment guides
│   ├── environment-setup.md
│   ├── ci-cd-pipeline.md
│   ├── monitoring.md
│   ├── backup-recovery.md
│   └── troubleshooting.md
├── UserGuides/                     # End-user documentation
│   ├── owner-app-guide.md
│   ├── vet-pro-guide.md
│   ├── rider-guide.md
│   └── admin-guide.md
└── Development/                    # Development documentation
    ├── getting-started.md
    ├── coding-standards.md
    ├── testing-guidelines.md
    ├── contribution-guide.md
    └── release-process.md
```

## Integration Points

### Cross-App Data Flow
```
Data Flow Architecture:
Owner App ←→ Shared Database ←→ VetPro App
    ↓              ↓                    ↓
  SOS Request → Dispatcher → Rider App Assignment
    ↓              ↓                    ↓
Real-time Updates ← WebSocket Server ← Live GPS Tracking
    ↓              ↓                    ↓
Push Notifications ← Notification Service ← All Apps
    ↓              ↓                    ↓
Admin Oversight ← Central Admin ← System Monitoring
```

### Shared Dependencies
- **Authentication**: Role-based auth system shared across all apps
- **Database**: CloudKit/Firebase with real-time synchronization
- **WebSocket**: Real-time communication server for chat and GPS tracking
- **Push Notifications**: Cross-app notification system
- **File Storage**: Shared cloud storage for documents and images
- **Analytics**: Centralized analytics and monitoring system

This comprehensive structure ensures maintainability, scalability, and clear separation of concerns while enabling seamless cross-app integration and real-time functionality.