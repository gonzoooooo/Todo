// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TodoApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "TodoFeature", targets: ["TodoFeature"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "DatabaseClients",
                "NotificationClient"
            ]
        ),
        .target(
            name: "CommonViews"
        ),
        .target(
            name: "CoreDataModels",
            resources: [
              .copy("TodoApp.xcdatamodeld")
            ]
        ),
        .target(
            name: "DatabaseClients",
            dependencies: [
                "CoreDataModels",
            ]
        ),
        .target(
            name: "NotificationClient"
        ),
        .target(
            name: "NotificationHelper",
            dependencies: [
                "NotificationClient"
            ]
        ),
        .target(
            name: "TodoFeature",
            dependencies: [
                "CommonViews",
                "CoreDataModels",
                "DatabaseClients",
                "NotificationClient",
                "NotificationHelper"
            ]
        ),
    ]
)
