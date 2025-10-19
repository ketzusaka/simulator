// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Simulator",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Simulator", targets: ["Simulator"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.20.0")
    ],
    targets: [
        .executableTarget(
            name: "Simulator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]
        ),
        .testTarget(
            name: "SimulatorTests",
            dependencies: ["Simulator"]
        )
    ]
)
