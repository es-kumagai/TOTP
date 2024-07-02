// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TOTP",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TOTP",
            targets: ["TOTP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/es-kumagai/Ocean.git", "0.2.2" ..< "0.3.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "3.3.0" ..< "4.0.0"),
    ],
    targets: [
        .target(
            name: "TOTP",
            dependencies: [
                "Ocean",
                .product(name: "Crypto", package: "swift-crypto")]
        ),
        .testTarget(
            name: "TOTPTests",
            dependencies: ["TOTP"]),
    ]
)
