// swift-tools-version: 5.9
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
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.6.0")
    ],
    targets: [
        .target(
            name: "PetReadyShared",
            dependencies: [
                "Alamofire",
                "Kingfisher",
                .product(name: "RealmSwift", package: "realm-swift"),
                "Starscream",
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk", condition: .when(platforms: [.iOS]))
            ],
            path: "SharedCode/Sources/PetReadyShared"
        ),
        .testTarget(
            name: "PetReadySharedTests",
            dependencies: ["PetReadyShared"],
            path: "SharedCode/Tests/PetReadySharedTests"
        )
    ]
)
