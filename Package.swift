// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Wishlist",
    platforms: [
       .macOS(.v10_12)
    ],
    products: [
        .library(name: "WishlistLibrary", targets: [ "Library" ]),
        .library(name: "WishlistDomain", targets: [ "Domain" ]),
        .executable(name: "Wishlist", targets: [ "Run" ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-nio-ssl-support.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.3.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.1"),
        .package(url: "https://github.com/edmw/Imperial.git", .branch("edmw")),
        .package(url: "https://github.com/edmw/Lingo.git", .branch("edmw")),
        .package(url: "https://github.com/LiveUI/VaporTestTools.git", from: "0.1.7"),
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git", .exact("1.8.0")),
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP", .exact("5.1.0")),
        .package(url: "https://github.com/ianpartridge/swift-backtrace.git", from: "1.1.1")
    ],
    targets: [
        .target(
            name: "Tooling",
            dependencies: []
        ),
        .target(
            name: "Library",
            dependencies: [ "Tooling" ]
        ),
        .target(
            name: "Domain",
            dependencies: [
                "Tooling",
                "Library",
                "NIO"
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                "Domain",
                "Tooling",
                "Library",
                "Vapor",
                "Leaf",
                "Authentication",
                "Crypto",
                "FluentSQLite",
                "FluentMySQL",
                "Imperial",
                "Lingo",
                "SwiftSMTP"
            ]
        ),
        .target(
            name: "Run",
            dependencies: [
                "App",
                "Backtrace"
            ]
        ),
        .target(
            name: "Testing",
            dependencies: [
                "Library"
            ],
            path: "Tests/Testing"
        ),
        .testTarget(
            name: "LibraryTests",
            dependencies: [
                "Testing",
                "Library"
            ],
            path: "Tests/LibraryTests"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Testing",
                "Domain"
            ],
            path: "Tests/DomainTests"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "Testing",
                "App",
                "VaporTestTools",
                "LoggerAPI"
            ],
            path: "Tests/AppTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
