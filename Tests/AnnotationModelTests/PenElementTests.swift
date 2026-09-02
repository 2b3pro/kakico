import XCTest
import CoreGraphics
@testable import AnnotationModel

final class PenElementTests: XCTestCase {

    private func stroke() -> PenElement {
        PenElement(points: [CGPoint(x: 10, y: 10), CGPoint(x: 60, y: 10), CGPoint(x: 60, y: 50)], width: 8)
    }

    func testBoundingBoxCoversPointsPlusHalfWidth() {
        XCTAssertEqual(stroke().boundingBox(), CGRect(x: 6, y: 6, width: 58, height: 48))
    }

    func testHitTestFollowsThePathNotTheBoundingBox() {
        let s = stroke()
        XCTAssertTrue(s.hitTest(CGPoint(x: 35, y: 12), tolerance: 0), "on the first segment")
        XCTAssertTrue(s.hitTest(CGPoint(x: 62, y: 30), tolerance: 0), "on the second segment")
        XCTAssertFalse(s.hitTest(CGPoint(x: 20, y: 40), tolerance: 0), "inside the bbox but off the path")
    }

    func testSinglePointIsADotHit() {
        let dot = PenElement(points: [CGPoint(x: 5, y: 5)], width: 8)
        XCTAssertTrue(dot.hitTest(CGPoint(x: 8, y: 5), tolerance: 0))
        XCTAssertFalse(dot.hitTest(CGPoint(x: 20, y: 5), tolerance: 0))
    }

    func testCreationDragAppendsPointsAndSkipsRestingPointer() {
        var s = PenElement(points: [CGPoint(x: 0, y: 0)])
        s.moveHandle(.end, to: CGPoint(x: 10, y: 0))
        s.moveHandle(.end, to: CGPoint(x: 10.2, y: 0))   // pointer resting
        s.moveHandle(.end, to: CGPoint(x: 20, y: 5))
        XCTAssertEqual(s.points, [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0), CGPoint(x: 20, y: 5)])
        s.moveHandle(.topLeft, to: .zero)
        XCTAssertEqual(s.points.count, 3, "only .end appends")
    }

    func testNoHandlesSoStrokesAreNotResizable() {
        XCTAssertTrue(stroke().handles().isEmpty)
    }

    func testTranslateMovesEveryPoint() {
        var s = stroke()
        s.translate(by: CGVector(dx: 1, dy: -2))
        XCTAssertEqual(s.points.first, CGPoint(x: 11, y: 8))
        XCTAssertEqual(s.points.last, CGPoint(x: 61, y: 48))
    }

    func testCodableRoundTrip() throws {
        let s = PenElement(points: [CGPoint(x: 1, y: 2), CGPoint(x: 3, y: 4)], color: .yellow, width: 14, opacity: 0.4)
        let data = try JSONEncoder().encode(Annotation.pen(s))
        XCTAssertEqual(try JSONDecoder().decode(Annotation.self, from: data), .pen(s))
    }

    func testAnnotationAccessors() {
        var a = Annotation.pen(stroke())
        XCTAssertEqual(a.strokeWidth, 8)
        XCTAssertEqual(a.opacity, 1)
        XCTAssertEqual(a.color, .red)
        a.opacity = 0.3
        a.strokeWidth = 12
        XCTAssertEqual(a.opacity, 0.3)
        XCTAssertEqual(a.strokeWidth, 12)
        var arrow = Annotation.arrow(SegmentElement(start: .zero, end: CGPoint(x: 1, y: 1)))
        XCTAssertNil(arrow.opacity)
        arrow.opacity = 0.5
        XCTAssertNil(arrow.opacity)
    }

    func testClickPlacementKeepsTheDot() {
        let a = Annotation.pen(PenElement(points: [CGPoint(x: 5, y: 5)]))
        XCTAssertEqual(a.applyingDefaultInitialSize(canvasSize: CGSize(width: 1200, height: 1000)), a)
    }
}
