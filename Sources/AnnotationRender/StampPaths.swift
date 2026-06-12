import CoreGraphics
import AnnotationModel

/// Original vector stamp shapes (drawn from scratch — no imported artwork).
enum StampPaths {
    static func path(for kind: StampKind, in rect: CGRect) -> CGPath {
        let p = CGMutablePath()
        let w = rect.width, h = rect.height
        func pt(_ fx: CGFloat, _ fy: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + fx * w, y: rect.minY + fy * h)
        }
        switch kind {
        case .check:
            p.move(to: pt(0.12, 0.55))
            p.addLine(to: pt(0.40, 0.82))
            p.addLine(to: pt(0.88, 0.20))
            p.addLine(to: pt(0.78, 0.10))
            p.addLine(to: pt(0.40, 0.62))
            p.addLine(to: pt(0.22, 0.45))
            p.closeSubpath()
        case .cross:
            let t: CGFloat = 0.16
            p.move(to: pt(0.10, 0.10 + t))
            p.addLine(to: pt(0.10 + t, 0.10))
            p.addLine(to: pt(0.50, 0.50 - t))
            p.addLine(to: pt(0.90 - t, 0.10))
            p.addLine(to: pt(0.90, 0.10 + t))
            p.addLine(to: pt(0.50 + t, 0.50))
            p.addLine(to: pt(0.90, 0.90 - t))
            p.addLine(to: pt(0.90 - t, 0.90))
            p.addLine(to: pt(0.50, 0.50 + t))
            p.addLine(to: pt(0.10 + t, 0.90))
            p.addLine(to: pt(0.10, 0.90 - t))
            p.addLine(to: pt(0.50 - t, 0.50))
            p.closeSubpath()
        case .star:
            let cx: CGFloat = 0.5, cy: CGFloat = 0.5
            let outer: CGFloat = 0.45, inner: CGFloat = 0.18
            for i in 0..<10 {
                let r = i % 2 == 0 ? outer : inner
                let a = (CGFloat(i) * .pi / 5) - .pi / 2
                let point = pt(cx + r * cos(a), cy + r * sin(a))
                if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
            }
            p.closeSubpath()
        case .exclaim:
            p.addRoundedRect(in: CGRect(x: rect.minX + 0.40 * w, y: rect.minY + 0.08 * h,
                                        width: 0.20 * w, height: 0.56 * h),
                             cornerWidth: 0.10 * w, cornerHeight: 0.10 * w)
            p.addEllipse(in: CGRect(x: rect.minX + 0.38 * w, y: rect.minY + 0.74 * h,
                                    width: 0.24 * w, height: 0.18 * h))
        case .heart:
            p.move(to: pt(0.50, 0.90))
            p.addCurve(to: pt(0.02, 0.32), control1: pt(0.20, 0.70), control2: pt(0.02, 0.50))
            p.addArc(center: pt(0.26, 0.28), radius: 0.24 * w, startAngle: .pi, endAngle: 0, clockwise: false)
            p.addArc(center: pt(0.74, 0.28), radius: 0.24 * w, startAngle: .pi, endAngle: 0, clockwise: false)
            p.addCurve(to: pt(0.50, 0.90), control1: pt(0.98, 0.50), control2: pt(0.80, 0.70))
            p.closeSubpath()
        }
        return p
    }
}
