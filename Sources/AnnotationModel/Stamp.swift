import Foundation
import CoreGraphics

/// The five Skitch stamp glyphs.
public enum StampKind: String, Codable, Equatable, Sendable, CaseIterable {
    case check, cross, exclaim, question, heart
}

/// A Skitch-style icon stamp: a colored disk with a white glyph and a
/// map-pin tail that can be swung around the disk to point at something.
/// Geometry is a center plus a radius; the tail direction is an angle in
/// model space (y-down, so `π/2` points down the image).
public struct StampElement: Codable, Equatable, Sendable, AnnotationGeometry {
    /// Default disk radius at the reference canvas size.
    public static let referenceRadius: CGFloat = 30
    public static let radiusRange: ClosedRange<CGFloat> = 8...300
    /// Tail tip distance from the center, in radii.
    public static let tailReach: CGFloat = 1.7
    /// Half-angle of the tail's base on the disk, in radians.
    public static let tailHalfAngle: CGFloat = .pi / 4

    public static func defaultRadius(forCanvasSize size: CGSize) -> CGFloat {
        DefaultSizeScale.scaledDefault(reference: referenceRadius, clampedTo: radiusRange, forCanvasSize: size)
    }

    public var id: ElementID
    public var center: CGPoint
    public var radius: CGFloat
    public var kind: StampKind
    public var color: RGBAColor
    /// Tail direction in radians, model space (y-down). Defaults to pointing down.
    public var pointerAngle: CGFloat

    public init(id: ElementID = UUID(), center: CGPoint, radius: CGFloat = StampElement.referenceRadius,
                kind: StampKind = .check, color: RGBAColor = .red, pointerAngle: CGFloat = .pi / 2) {
        self.id = id; self.center = center; self.radius = radius
        self.kind = kind; self.color = color; self.pointerAngle = pointerAngle
    }

    /// Where the tail ends.
    public var tailTip: CGPoint {
        CGPoint(x: center.x + cos(pointerAngle) * radius * Self.tailReach,
                y: center.y + sin(pointerAngle) * radius * Self.tailReach)
    }

    /// The disk's bounding square.
    public var diskRect: CGRect {
        CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    }

    /// Resize handle position: on the disk edge, upper-right in image terms.
    private var resizeHandlePosition: CGPoint {
        let a = -CGFloat.pi / 4
        return CGPoint(x: center.x + cos(a) * radius, y: center.y + sin(a) * radius)
    }

    public func boundingBox() -> CGRect {
        // The halo and shadow spill a little past the disk and tail.
        let margin = radius * 0.15
        return diskRect.union(CGRect(origin: tailTip, size: .zero)).insetBy(dx: -margin, dy: -margin)
    }

    public func hitTest(_ point: CGPoint, tolerance: CGFloat) -> Bool {
        if GeometryMath.distance(from: point, to: center) <= radius + tolerance { return true }
        return GeometryMath.distance(from: point, toSegment: center, tailTip) <= radius * 0.35 + tolerance
    }

    public func handles() -> [Handle] {
        [Handle(role: .end, position: tailTip),
         Handle(role: .topRight, position: resizeHandlePosition)]
    }

    public mutating func moveHandle(_ role: HandleRole, to point: CGPoint) {
        switch role {
        case .end:
            guard GeometryMath.distance(from: point, to: center) > 0.5 else { return }
            pointerAngle = atan2(point.y - center.y, point.x - center.x)
        case .topRight:
            radius = min(Self.radiusRange.upperBound,
                         max(Self.radiusRange.lowerBound, GeometryMath.distance(from: point, to: center)))
        default:
            break
        }
    }

    public mutating func translate(by delta: CGVector) {
        center.x += delta.dx; center.y += delta.dy
    }
}
