// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BrainrotClone",
    platforms: [.iOS(.v17)],
    products: [
        .iOSApplication(name: "BrainrotClone", targets: ["App"])
    ],
    targets: [
        .executableTarget(
            name: "App",
            path: "Sources"
        )
    ]
)
