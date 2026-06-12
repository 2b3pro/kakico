// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Snapmark",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Snapmark", targets: ["Snapmark"]),
        .library(name: "AnnotationModel", targets: ["AnnotationModel"]),
        .library(name: "AnnotationRender", targets: ["AnnotationRender"]),
    ],
    targets: [
        .target(name: "AnnotationModel"),
        .target(name: "AnnotationRender", dependencies: ["AnnotationModel"]),
        .executableTarget(
            name: "Snapmark",
            dependencies: ["AnnotationModel", "AnnotationRender"]
        ),
        .testTarget(name: "AnnotationModelTests", dependencies: ["AnnotationModel"]),
        .testTarget(name: "AnnotationRenderTests", dependencies: ["AnnotationModel", "AnnotationRender"]),
    ]
)
