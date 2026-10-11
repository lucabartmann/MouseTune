// swift-tools-version:5.9
import PackageDescription
let package = Package(
    name: "MouseTune",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "MouseTune", path: "Sources/MouseTune"),
        .testTarget(name: "MouseTuneTests", dependencies: ["MouseTune"], path: "Tests/MouseTuneTests"),
    ]
)
