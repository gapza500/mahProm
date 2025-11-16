# PetReady Phase 1 Technical Setup Requirements

## Overview

This document outlines the complete technical setup requirements for Phase 1 of the PetReady multi-app ecosystem development. Phase 1 focuses on establishing the foundation architecture, shared code modules, and basic infrastructure for all 4 applications.

## Prerequisites

### Development Environment
- **macOS**: Monterey (12.0) or later
- **Xcode**: 16.0 or later with iOS 16+ SDK
- **Swift**: 5.7 or later
- **iOS Simulator**: iPhone 14 or later models
- **Node.js**: 18.0 or later (for backend development)
- **Git**: Version 2.30 or later

### Apple Developer Account
- **Paid Apple Developer Account**: Required for push notifications, CloudKit, and app distribution
- **Team ID**: For bundle identifier management
- **Certificates and Provisioning Profiles**: For all 4 applications

### Cloud Services Setup
- **Apple ID**: For CloudKit dashboard access
- **Firebase Account**: (Alternative to CloudKit) for real-time database and authentication
- **Google Maps API Key**: For map integration and geocoding
- **Push Notification Service**: APNs certificate setup

## Phase 1 Setup Tasks

### 1. Project Structure Creation

#### 1.1 Root Directory Setup
```bash
# Create main ecosystem directory
mkdir PetReady-Ecosystem
cd PetReady-Ecosystem

# Initialize Git repository
git init

# Create directory structure
mkdir -p {Scripts,Tools,Config,Documentation/{API,Architecture,Deployment,UserGuides,Development}}
mkdir -p PetReady-{Owner,VetPro,Rider,CentralAdmin}
mkdir -p SharedCode Backend
```

#### 1.2 Xcode Workspace Creation
```bash
# Create workspace
cd PetReady-Ecosystem
petready workspace create PetReady.xcworkspace

# Add projects to workspace (to be done after creating individual projects)
```

#### 1.3 Individual App Creation
For each app (Owner, VetPro, Rider, CentralAdmin):

```bash
# Create SwiftUI app project
cd PetReady-Owner
petready project create PetReadyOwner --platform iOS --language Swift --interface SwiftUI

# Repeat for other apps
cd ../PetReady-VetPro
petready project create PetReadyVetPro --platform iOS --language Swift --interface SwiftUI

cd ../PetReady-Rider
petready project create PetReadyRider --platform iOS --language Swift --interface SwiftUI

cd ../PetReady-CentralAdmin
petready project create PetReadyCentralAdmin --platform iOS --language Swift --interface SwiftUI
```

### 2. Shared Code Module Setup

#### 2.1 Swift Package Creation
```bash
cd SharedCode
petready package create PetReadyShared --type library
```

#### 2.2 Package.swift Configuration
```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "PetReadyShared",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PetReadyShared",
            targets: ["PetReadyShared"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "PetReadyShared",
            dependencies: [
                "Alamofire",
                "Kingfisher",
                "RealmSwift",
                "Starscream"
            ]
        ),
        .testTarget(
            name: "PetReadySharedTests",
            dependencies: ["PetReadyShared"]
        ),
    ]
)
```

#### 2.3 Shared Module Structure
```bash
cd PetReady-Ecosystem/SharedCode/Sources/PetReadyShared
mkdir -p {Models,Services,Utilities,Networking,Resources}
mkdir -p Models/{User,Pet,Clinic,Message,Transport,Admin,Government}
mkdir -p Services/{Auth,Network,WebSocket,Notification,GPS,CloudSync,Validation}
mkdir -p Utilities/{Extensions,Formatters,Validators,Helpers}
mkdir -p Networking/{API,WebSocket,Monitor}
mkdir -p Resources/{Colors,Fonts,Images,Localization}
```

### 3. Backend Services Setup

#### 3.1 Node.js Backend Initialization
```bash
cd PetReady-Ecosystem/Backend
npm init -y

# Install dependencies
npm install express cors helmet morgan dotenv
npm install socket.io jsonwebtoken bcryptjs
npm install multer aws-sdk firebase-admin
npm install mongoose redis ioredis
npm install jest supertest nodemon --save-dev
```

#### 3.2 Backend Structure Creation
```bash
cd PetReady-Ecosystem/Backend
mkdir -p src/{API,Database,WebSocket,Services,Middleware,Utils,Cloud}
mkdir -p src/API/{auth,pets,clinics,chat,transport,admin,websocket}
mkdir -p src/Database/{models,migrations,seeds,connections}
mkdir -p config
mkdir -p tests/{unit,integration,load}
mkdir -p deployment/{docker,kubernetes,terraform,scripts}
```

#### 3.3 Environment Configuration
```javascript
// config/development.js
module.exports = {
  port: process.env.PORT || 3000,
  database: {
    url: process.env.DB_URL || 'mongodb://localhost:27017/petready-dev'
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret-key',
    expiresIn: '7d'
  },
  cloudServices: {
    aws: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_REGION || 'us-east-1'
    },
    firebase: {
      credentials: process.env.FIREBASE_CREDENTIALS
    }
  }
};
```

### 4. Cloud Database Setup

#### 4.1 CloudKit Configuration
```swift
// SharedCode/Sources/PetReadyShared/Services/CloudSyncService.swift
import CloudKit
import Foundation

class CloudSyncService: ObservableObject {
    private let container: CKContainer
    private let database: CKDatabase

    init() {
        self.container = CKContainer(identifier: "icloud.com.petready.shared")
        self.database = container.privateCloudDatabase
    }

    // Sync implementation methods
}
```

#### 4.2 CloudKit Dashboard Setup
1. **Apple Developer Portal**: Sign in and navigate to CloudKit Dashboard
2. **Create Container**: `iCloud.com.petready.shared`
3. **Configure Record Types**: User, Pet, Clinic, Message, etc.
4. **Set Up Subscriptions**: For real-time data synchronization
5. **Configure Security**: Roles and permissions

### 5. WebSocket Server Setup

#### 5.1 Basic WebSocket Server
```javascript
// Backend/src/WebSocket/server.js
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Socket connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Handle different event types
  socket.on('join-chat', (conversationId) => {
    socket.join(conversationId);
  });

  socket.on('message', (data) => {
    // Handle message broadcasting
  });

  socket.on('location-update', (data) => {
    // Handle GPS tracking
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`WebSocket server running on port ${PORT}`);
});
```

### 6. Authentication System Setup

#### 6.1 Shared Authentication Service
```swift
// SharedCode/Sources/PetReadyShared/Services/AuthService.swift
import Foundation
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private let apiClient: APIClient
    private let keychainService: KeychainService

    init() {
        self.apiClient = APIClient()
        self.keychainService = KeychainService()
    }

    func login(phone: String, otp: String) -> AnyPublisher<User, Error> {
        // Implementation
    }

    func verifyOTP(code: String) -> AnyPublisher<AuthToken, Error> {
        // Implementation
    }

    func logout() {
        // Implementation
    }
}
```

### 7. Core Data Integration

#### 7.1 Shared Core Data Stack
```swift
// SharedCode/Sources/PetReadyShared/Services/CoreDataService.swift
import CoreData
import CloudKit

class CoreDataService: ObservableObject {
    static let shared = CoreDataService()

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "PetReady")

        // Configure CloudKit integration
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
```

### 8. Configuration Management

#### 8.1 Feature Flags Configuration
```yaml
# Config/feature-flags.yml
features:
  chat:
    enabled: true
    max_queue_time: 900  # 15 minutes
  sos:
    enabled: true
    max_response_time: 300  # 5 minutes
  payments:
    enabled: false  # Prototype only
  government_announcements:
    enabled: true
    priority_levels: ["low", "medium", "high", "critical"]

app_settings:
  owner_app:
    features: ["pets", "health", "clinics", "chat", "sos", "information"]
  vet_pro_app:
    features: ["patients", "consultations", "clinic_admin", "analytics"]
  rider_app:
    features: ["jobs", "navigation", "money_pocket", "analytics"]
  admin_app:
    features: ["user_management", "system_monitoring", "announcements", "analytics"]
```

### 9. Integration Testing Setup

#### 9.1 Cross-App Test Framework
```swift
// SharedCode/Tests/PetReadySharedTesting/IntegrationTestHelpers.swift
import XCTest
import Combine

class IntegrationTestHelpers: XCTestCase {
    static let shared = IntegrationTestHelpers()

    func setupTestEnvironment() {
        // Reset test database
        // Clear test caches
        // Mock authentication
    }

    func createTestUser(type: UserType) -> User {
        // Create test user for specific app type
    }

    func createTestPet(owner: User) -> Pet {
        // Create test pet
    }

    func simulateCrossAppInteraction() {
        // Test data synchronization between apps
    }
}
```

### 10. Build System Configuration

#### 10.1 Shared Build Scripts
```bash
#!/bin/bash
# Scripts/build-all.sh

echo "Building PetReady Multi-App Ecosystem..."

# Build shared module first
echo "Building SharedCode..."
cd SharedCode
swift build

# Build each app
apps=("Owner" "VetPro" "Rider" "CentralAdmin")

for app in "${apps[@]}"; do
    echo "Building PetReady-${app}..."
    cd "../PetReady-${app}"
    xcodebuild -scheme "PetReady${app}" -configuration Debug build
done

echo "Build completed successfully!"
```

### 11. Development Environment Setup

#### 11.1 Development Setup Script
```bash
#!/bin/bash
# Scripts/setup-development.sh

echo "Setting up PetReady development environment..."

# Check prerequisites
if ! command -v xcodebuild &> /dev/null; then
    echo "Xcode is required but not installed."
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "Node.js is required but not installed."
    exit 1
fi

# Clone repositories and install dependencies
echo "Installing dependencies..."
cd Backend && npm install
cd ../SharedCode && swift package resolve
cd ..

# Create configuration files
echo "Creating configuration files..."
cp Config/development.yml.example Config/development.yml

echo "Development environment setup complete!"
echo "Next steps:"
echo "1. Configure your Apple Developer account"
echo "2. Set up CloudKit container"
echo "3. Configure environment variables in Config/development.yml"
echo "4. Run './Scripts/build-all.sh' to build all apps"
```

## Verification Checklist

### Phase 1 Completion Criteria

- [ ] **Directory Structure**: All 4 app projects created with correct folder structure
- [ ] **Shared Module**: Swift package created with common models and services
- [ ] **Backend Server**: Node.js server with WebSocket and API endpoints
- [ ] **Database**: CloudKit container configured with basic record types
- [ ] **Authentication**: Phone/email verification system implemented
- [ ] **Build System**: Scripts for building all apps and running tests
- [ ] **Workspace**: Xcode workspace with all 4 app projects and shared module
- [ ] **Configuration**: Environment configurations for development, staging, production
- [ ] **Documentation**: Initial API documentation and setup guides
- [ ] **Integration Tests**: Basic cross-app testing framework

### Technical Validation

- [ ] All apps compile without errors
- [ ] Shared module imports correctly in all apps
- [ ] WebSocket server connects and accepts connections
- [ ] Authentication flow works between apps and backend
- [ ] CloudKit synchronization is configured
- [ ] Build scripts execute successfully
- [ ] Basic integration tests pass

## Next Steps

After completing Phase 1 setup:

1. **Begin Phase 2 Development**: Start implementing core features for each app
2. **Set Up CI/CD**: Configure automated building and testing
3. **Environment Deployment**: Set up staging environment for integration testing
4. **Team Onboarding**: Set up development environments for team members
5. **Monitor and Iterate**: Set up monitoring and begin iterative development

This comprehensive setup provides a solid foundation for developing the PetReady multi-app ecosystem with proper separation of concerns, shared infrastructure, and scalable architecture.