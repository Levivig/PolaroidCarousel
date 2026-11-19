// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PolaroidCarousel",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "PolaroidCarousel", targets: ["PolaroidCarousel"])],
    targets: [
        .target(name: "PolaroidCarousel", resources: [.process("Resources")]),
        .testTarget(name: "PolaroidCarouselTests", dependencies: ["PolaroidCarousel"]),
    ]
)
