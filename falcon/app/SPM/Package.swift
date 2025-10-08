// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "FalconDependencies",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "FalconDependencies", targets: ["Dummy"])
    ],
    dependencies: [
        // Animations
        .package(url: "https://github.com/airbnb/lottie-spm.git", exact: "4.0.1"),

        // gRPC
        .package(url: "https://github.com/grpc/grpc-swift.git", exact: "1.24.2")
    ],
    targets: [
        .target(
            name: "Dummy",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "GRPC", package: "grpc-swift")
            ],
            path: "Sources"
        )
    ]
)
