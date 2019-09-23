// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Wishlist",
    products: [
    	.executable(name: "Wishlist", targets: ["Run"])
    ],
// Swift 5:
//    platforms: [
//       .macOS(.v10_12),
//    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.3.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.1"),
        .package(url: "https://github.com/vapor-community/Imperial.git", from: "0.7.1"),
        .package(url: "https://github.com/miroslavkovac/Lingo.git", from: "3.0.5"),
        .package(url: "https://github.com/malcommac/SwiftDate.git", from: "5.0.0"),
        .package(url: "https://github.com/LiveUI/VaporTestTools.git", from: "0.1.7"),
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git", .exact("1.8.0")),
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP", .exact("5.1.0"))
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "Leaf",
            "Authentication",
            "Crypto",
            "FluentSQLite",
            "FluentMySQL",
            "Imperial",
            "Lingo",
            "SwiftDate",
            "SwiftSMTP"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "VaporTestTools"])
    ]
)
