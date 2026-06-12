import XCTest
import CoreGraphics
@testable import AnnotationModel

final class AnnotationModelTests: XCTestCase {

    func testDistanceToSegment() {
        let d = GeometryMath.distance(from: CGPoint(x: 5, y: 5),
                                      toSegment: CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0))
        XCTAssertEqual(d, 5, accuracy: 0.0001)
        // Beyond the segment end clamps to the endpoint.
        let d2 = GeometryMath.distance(from: CGPoint(x: 20, y: 0),
                                       toSegment: CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0))
        XCTAssertEqual(d2, 10, accuracy: 0.0001)
    }

    func testRectFromCornersHandlesNegativeDrag() {
        let r = CGRect(corner: CGPoint(x: 10, y: 10), CGPoint(x: 0, y: 0))
        XCTAssertEqual(r, CGRect(x: 0, y: 0, width: 10, height: 10))
    }

    func testArrowHitTest() {
        let arrow = ArrowElement(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 100, y: 0), width: 6)
        XCTAssertTrue(arrow.hitTest(CGPoint(x: 50, y: 3), tolerance: 8))
        XCTAssertFalse(arrow.hitTest(CGPoint(x: 50, y: 40), tolerance: 8))
    }

    func testShapeStrokedHitTestEdgeOnly() {
        let shape = ShapeElement(rect: CGRect(x: 0, y: 0, width: 100, height: 100), width: 4)
        XCTAssertTrue(shape.hitTest(CGPoint(x: 0, y: 50), tolerance: 6))   // on the edge
        XCTAssertFalse(shape.hitTest(CGPoint(x: 50, y: 50), tolerance: 6)) // deep inside, no fill
    }

    func testShapeFilledHitTestInside() {
        let shape = ShapeElement(rect: CGRect(x: 0, y: 0, width: 100, height: 100), width: 4, fill: .red)
        XCTAssertTrue(shape.hitTest(CGPoint(x: 50, y: 50), tolerance: 0))
    }

    func testMoveHandleResizesShape() {
        var ann = Annotation.rectangle(ShapeElement(rect: CGRect(x: 0, y: 0, width: 100, height: 100)))
        ann.moveHandle(.bottomRight, to: CGPoint(x: 200, y: 150))
        if case .rectangle(let e) = ann {
            XCTAssertEqual(e.rect, CGRect(x: 0, y: 0, width: 200, height: 150))
        } else {
            XCTFail("kind changed")
        }
    }

    func testTranslatePreservesKind() {
        var ann = Annotation.arrow(ArrowElement(start: .zero, end: CGPoint(x: 10, y: 0)))
        ann.translate(by: CGVector(dx: 5, dy: 5))
        guard case .arrow(let e) = ann else { return XCTFail("kind changed") }
        XCTAssertEqual(e.start, CGPoint(x: 5, y: 5))
        XCTAssertEqual(e.end, CGPoint(x: 15, y: 5))
    }

    func testDocumentTopmostHitTest() {
        let bottom = Annotation.rectangle(ShapeElement(rect: CGRect(x: 0, y: 0, width: 100, height: 100), fill: .blue))
        let top = Annotation.rectangle(ShapeElement(rect: CGRect(x: 0, y: 0, width: 100, height: 100), fill: .red))
        let doc = Document(baseImage: .file(path: "/x.png"), canvasSize: CGSize(width: 200, height: 200),
                           elements: [bottom, top])
        XCTAssertEqual(doc.hitTest(CGPoint(x: 50, y: 50), tolerance: 0), top.id)
    }

    func testDocumentCodableRoundTrip() throws {
        let doc = Document(
            baseImage: .pngData(Data([0, 1, 2, 3])),
            canvasSize: CGSize(width: 640, height: 480),
            elements: [
                .arrow(ArrowElement(start: .zero, end: CGPoint(x: 100, y: 100))),
                .text(TextElement(origin: CGPoint(x: 10, y: 10), string: "hi")),
                .blur(RedactionElement(rect: CGRect(x: 0, y: 0, width: 50, height: 50), amount: 12)),
            ],
            crop: CGRect(x: 5, y: 5, width: 100, height: 100))
        let data = try JSONEncoder().encode(doc)
        let decoded = try JSONDecoder().decode(Document.self, from: data)
        XCTAssertEqual(doc, decoded)
    }
}
