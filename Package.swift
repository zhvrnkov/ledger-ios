// swift-tools-version:5.6.0

import PackageDescription

let package = Package(
    name: "Example",
    products: [
        .library(
            name: "Ledger",
            targets: ["Ledger"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bizz84/SwiftyStoreKit", exact: "0.16.3"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", exact: "4.2.2"),
        .package(url: "https://github.com/MobileNativeFoundation/Kronos", exact: "4.2.1"),
        .package(url: "https://github.com/zhvrnkov/ion", branch: "master")
    ],
    targets: [
        .target(name: "Ledger", dependencies: ["SwiftyStoreKit", "KeychainAccess", "Kronos", .product(name: "Ion", package: "ion")])
    ]
)
