// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "AsyncNetworkService",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AsyncNetworkService",
            targets: ["AsyncNetworkService"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.0.0"),
    ],
    targets: [
        .target(
            name: "AsyncNetworkService",
            dependencies: [],
            path: "./AsyncNetworkService"
        ),
        .testTarget(
            name: "AsyncNetworkServiceTests",
            dependencies: ["OHHTTPStubs"],
            path: "./AsyncNetworkServiceTests"
        ),
    ]
)
