// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BackupKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v17),
    ],
    products: [
        .library(name: "BackupKit", targets: ["BackupKit"]),
    ],
    targets: [
        .target(name: "BackupKit"),
        .testTarget(name: "BackupKitTests", dependencies: ["BackupKit"]),
    ]
)