import XCTest
import CoreGraphics
@testable import AnnotationModel

final class StampElementTests: XCTestCase {

    private func stamp() -> StampElement {
        StampElement(center: CGPoint(x: 100, y: 100), radius: 20, kind: .check, color: .red)
    }

    func testDefaultPointerPointsDown() {
        let s = stamp()
        XCTAssertEqual(s.tailTip.x, 100, accuracy: 0.001)
        XCTAssertEqual(s.tailTip.y, 100 + 20 * StampElement.tailReach, accuracy: 0.001)
    }

    func testHitTestCoversDiskAndTailButNotFarAway() {
        let s = stamp()
        XCTAssertTrue(s.hitTest(CGPoint(x: 100, y: 100), tolerance: 0))
        XCTAssertTrue(s.hitTest(CGPoint(x: 118, y: 100), tolerance: 0))
        XCTAssertTrue(s.hitTest(CGPoint(x: 100, y: 128), tolerance: 0), "on the tail")
        XCTAssertFalse(s.hitTest(CGPoint(x: 100, y: 60), tolerance: 0))
        XCTAssertFalse(s.hitTest(CGPoint(x: 140, y: 140), tolerance: 0))
    }

    func testTailHandleSwingsThePointer() {
        var s = stamp()
        s.moveHandle(.end, to: CGPoint(x: 160, y: 100))   // drag the tip to the right
        XCTAssertEqual(s.pointerAngle, 0, accuracy: 0.001)
        XCTAssertEqual(s.tailTip.x, 100 + 20 * StampElement.tailReach, accuracy: 0.001)
        XCTAssertEqual(s.radius, 20, "swinging the tail must not resize")
    }

    func testResizeHandleChangesRadiusAndClamps() {
        var s = stamp()
        s.moveHandle(.topRight, to: CGPoint(x: 130, y: 60))
        XCTAssertEqual(s.radius, 50, accuracy: 0.001)
        s.moveHandle(.topRight, to: CGPoint(x: 101, y: 100))
        XCTAssertEqual(s.radius, StampElement.radiusRange.lowerBound)
        XCTAssertEqual(s.center, CGPoint(x: 100, y: 100), "resizing keeps the center")
    }

    func testHandlesSitOnTipAndDiskEdge() {
        let s = stamp()
        let roles = s.handles().map(\.role)
        XCTAssertEqual(roles, [.end, .topRight])
        XCTAssertEqual(s.handles()[0].position, s.tailTip)
        XCTAssertEqual(GeometryMath.distance(from: s.handles()[1].position, to: s.center), 20, accuracy: 0.001)
    }

    func testBoundingBoxContainsDiskAndTip() {
        let s = stamp()
        let box = s.boundingBox()
        XCTAssertTrue(box.contains(s.diskRect))
        XCTAssertTrue(box.contains(s.tailTip))
    }

    func testTranslateMovesCenterAndTip() {
        var s = stamp()
        s.translate(by: CGVector(dx: 5, dy: -7))
        XCTAssertEqual(s.center, CGPoint(x: 105, y: 93))
        XCTAssertEqual(s.tailTip.x, 105, accuracy: 0.001)
    }

    func testCodableRoundTrip() throws {
        let s = StampElement(center: CGPoint(x: 3, y: 4), radius: 12, kind: .heart, color: .pink, pointerAngle: 1.2)
        let data = try JSONEncoder().encode(Annotation.stamp(s))
        XCTAssertEqual(try JSONDecoder().decode(Annotation.self, from: data), .stamp(s))
    }

    func testAnnotationAccessors() {
        var a = Annotation.stamp(stamp())
        XCTAssertEqual(a.stampKind, .check)
        XCTAssertNil(a.strokeWidth)
        XCTAssertEqual(a.color, .red)
        a.stampKind = .question
        XCTAssertEqual(a.stampKind, .question)
        var arrow = Annotation.arrow(SegmentElement(start: .zero, end: CGPoint(x: 1, y: 1)))
        XCTAssertNil(arrow.stampKind)
        arrow.stampKind = .heart
        XCTAssertNil(arrow.stampKind)
    }

    func testClickPlacementKeepsStampSize() {
        let a = Annotation.stamp(stamp())
        XCTAssertEqual(a.applyingDefaultInitialSize(canvasSize: CGSize(width: 1200, height: 1000)), a)
    }

    func testDefaultRadiusScalesWithCanvas() {
        XCTAssertEqual(StampElement.defaultRadius(forCanvasSize: DefaultSizeScale.referenceCanvasSize),
                       StampElement.referenceRadius)
        XCTAssertEqual(StampElement.defaultRadius(forCanvasSize: CGSize(width: 2400, height: 2000)),
                       StampElement.referenceRadius * 2)
    }

    /// The tail tip is a grabbable handle when the stamp is selected.
    func testResolvePointerFindsTailHandle() {
        let s = stamp()
        let doc = Document(baseImage: .file(path: "/x.png"), canvasSize: CGSize(width: 400, height: 400),
                           elements: [.stamp(s)])
        XCTAssertEqual(doc.resolvePointer(at: s.tailTip, selection: s.id, bodyTolerance: 8, handleTolerance: 8),
                       .handle(s.id, .end))
    }
}
