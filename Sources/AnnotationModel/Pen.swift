import Foundation
import CoreGraphics

/// A freehand stroke: the pointer's path, stroked at `width` with `opacity`.
/// At full opacity it is a pen; lowered, it is a highlighter. Strokes move
/// as a whole and are not resizable, so they expose no handles; `.end` is
/// accepted by `moveHandle` only so creation can append points through the
/// same drag path the other tools use.
public struct PenElement: Codable, Equatable, Sendable, AnnotationGeometry {
    public static let opacityRange: ClosedRange<CGFloat> = 0.1...1

    public var id: ElementID
    public var points: [CGPoint]
    public var color: RGBAColor
    public var width: CGFloat
    public var opacity: CGFloat

    public init(id: ElementID = UUID(), points: [CGPoint], color: RGBAColor = .red,
                width: CGFloat = 8, opacity: CGFloat = 1) {
        self.id = id; self.points = points; self.color = color
        self.width = width; self.opacity = opacity
    }

    public func boundingBox() -> CGRect {
        guard let first = points.first else { return .zero }
        var box = CGRect(origin: first, size: .zero)
        for p in points.dropFirst() { box = box.union(CGRect(origin: p, size: .zero)) }
        return box.insetBy(dx: -width / 2, dy: -width / 2)
    }

    public func hitTest(_ point: CGPoint, tolerance: CGFloat) -> Bool {
        let reach = max(tolerance, width / 2)
        guard let first = points.first else { return false }
        if points.count == 1 { return GeometryMath.distance(from: point, to: first) <= reach }
        for i in 1..<points.count
        where GeometryMath.distance(from: point, toSegment: points[i - 1], points[i]) <= reach {
            return true
        }
        return false
    }

    public func handles() -> [Handle] { [] }

    public mutating func moveHandle(_ role: HandleRole, to point: CGPoint) {
        guard role == .end else { return }
        // Skip points that would not move the stroke; keeps the path small
        // when the pointer rests.
        if let last = points.last, GeometryMath.distance(from: last, to: point) < 0.5 { return }
        points.append(point)
    }

    public mutating func translate(by delta: CGVector) {
        for i in points.indices {
            points[i].x += delta.dx
            points[i].y += delta.dy
        }
    }
}
