// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TodoApp",
    platforms: [
        .iOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "TodoFeature", targets: ["TodoFeature"]),
        .library(name: "WatchFeature", targets: ["WatchFeature"])
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
            name: "NotificationActions",
            dependencies: [
                "DatabaseClients"
            ]
        ),
        .target(
            name: "NotificationClient",
            dependencies: [
                "NotificationActions"
            ]
        ),
        .target(
            name: "NotificationHelper",
            dependencies: [
                "NotificationActions",
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
        .target(
            name: "WatchFeature",
            dependencies: [
                "CoreDataModels",
                "DatabaseClients"
            ]
        )
    ]
)
