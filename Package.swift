// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Kakico",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Kakico", targets: ["Kakico"]),
        .library(name: "AnnotationModel", targets: ["AnnotationModel"]),
        .library(name: "AnnotationRender", targets: ["AnnotationRender"]),
    ],
    targets: [
        .target(name: "AnnotationModel"),
        .target(name: "AnnotationRender", dependencies: ["AnnotationModel"]),
        .executableTarget(
            name: "Kakico",
            dependencies: ["AnnotationModel", "AnnotationRender"]
        ),
        .testTarget(name: "AnnotationModelTests", dependencies: ["AnnotationModel"]),
        .testTarget(name: "AnnotationRenderTests", dependencies: ["AnnotationModel", "AnnotationRender"]),
    ]
)
