// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SelfSignedCert",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "SelfSignedCert",
            targets: ["SelfSignedCert"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SelfSignedCert",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        .testTarget(
            name: "SelfSignedCertTests",
            dependencies: [
                "SelfSignedCert",
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            resources: [
                .process("Fixtures"),
            ]
        )
    ]
)
