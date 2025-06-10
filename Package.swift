// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Swazure",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(name: "Swazure", targets: ["Swazure"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "3.12.3"))
    ],
    targets: [
        .target(
            name: "Swazure",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto")
            ]
        )
    ],
    swiftLanguageModes: [.v5],
)
