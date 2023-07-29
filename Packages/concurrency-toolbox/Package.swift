// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "concurrency-toolbox",
    platforms: [.iOS(.v15), .tvOS(.v15), .macCatalyst(.v15), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ConcurrencyToolbox",
            targets: [
                "ConcurrencyToolbox"
            ]
        ),
        .executable(
            name: "ConcurrencyToolboxExample",
            targets: [
                "ConcurrencyToolboxExample"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-07-10-a"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ConcurrencyToolbox",
            dependencies: [
                "ConcurrencyToolboxMacros"
            ],
            path: "ConcurrencyToolbox",
            sources: ["Sources"]
        ),
        .macro(
            name: "ConcurrencyToolboxMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "ConcurrencyToolboxMacros",
            sources: ["Sources"]
        ),
        .testTarget(
            name: "ConcurrencyToolboxMacrosTests",
            dependencies: [
                "ConcurrencyToolboxMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "ConcurrencyToolboxMacros",
            sources: ["Tests"]
        ),
        .executableTarget(
            name: "ConcurrencyToolboxExample",
            dependencies: [
                "ConcurrencyToolbox",
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            path: "ConcurrencyToolboxExample",
            sources: ["Sources"]
        )
    ]
)
