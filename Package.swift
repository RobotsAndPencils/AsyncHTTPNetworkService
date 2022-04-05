// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AsyncNetworkService",
    products: [
        .library(
            name: "AsyncNetworkService",
            targets: ["AsyncNetworkService"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "AsyncNetworkService",
            dependencies: ["OHHTTPStubs"]
        ),
        .testTarget(
            name: "AsyncNetworkServiceTests",
            dependencies: ["OHHTTPStubs"]
        )
    ]
)
