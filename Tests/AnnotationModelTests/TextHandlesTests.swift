import XCTest
import CoreGraphics
@testable import AnnotationModel

final class TextHandlesTests: XCTestCase {

    private func text() -> TextElement {
        TextElement(origin: CGPoint(x: 20, y: 50), size: CGSize(width: 100, height: 40),
                    string: "hi", font: FontSpec(pointSize: 20))
    }

    func testTextExposesLeftRightAndFontSizeHandles() {
        let t = text()
        XCTAssertEqual(t.handles().map(\.role), [.left, .right, .bottomRight])
        XCTAssertEqual(t.handles()[0].position, CGPoint(x: 20, y: 70))
        XCTAssertEqual(t.handles()[1].position, CGPoint(x: 120, y: 70))
        XCTAssertEqual(t.handles()[2].position, CGPoint(x: 120, y: 90))
    }

    func testRightHandleSetsWidthKeepingLeftEdge() {
        var t = text()
        t.moveHandle(.right, to: CGPoint(x: 170, y: 99))
        XCTAssertEqual(t.rect, CGRect(x: 20, y: 50, width: 150, height: 40))
        t.moveHandle(.right, to: CGPoint(x: 0, y: 0))
        XCTAssertEqual(t.size.width, TextElement.minimumWidth, "clamped, never negative")
    }

    func testLeftHandleSetsWidthKeepingRightEdge() {
        var t = text()
        t.moveHandle(.left, to: CGPoint(x: 0, y: 99))
        XCTAssertEqual(t.rect, CGRect(x: 0, y: 50, width: 120, height: 40))
        t.moveHandle(.left, to: CGPoint(x: 200, y: 0))
        XCTAssertEqual(t.rect.maxX, 120)
        XCTAssertEqual(t.size.width, TextElement.minimumWidth)
    }

    func testBottomRightHandleScalesTheFont() {
        var t = text()
        t.moveHandle(.bottomRight, to: CGPoint(x: 120, y: 130))   // twice the height below the top
        XCTAssertEqual(t.font.pointSize, 40, accuracy: 0.001)
        XCTAssertEqual(t.size.width, 100, "font handle leaves the width alone")
        t.moveHandle(.bottomRight, to: CGPoint(x: 120, y: 50))
        XCTAssertEqual(t.font.pointSize, TextElement.pointSizeRange.lowerBound)
    }

    func testCornerHandlesOtherThanBottomRightDoNothing() {
        let original = text()
        var t = original
        t.moveHandle(.topLeft, to: .zero)
        XCTAssertEqual(t, original)
    }

    func testStyleCycleOrder() {
        XCTAssertEqual(TextStyle.shadow.next, .outline)
        XCTAssertEqual(TextStyle.outline.next, .plain)
        XCTAssertEqual(TextStyle.plain.next, .shadow)
    }

    func testPointerResolvesTheRightEdgeHandle() {
        let t = text()
        let doc = Document(baseImage: .file(path: "/x.png"), canvasSize: CGSize(width: 400, height: 400),
                           elements: [.text(t)])
        XCTAssertEqual(doc.resolvePointer(at: CGPoint(x: 121, y: 70), selection: t.id, bodyTolerance: 8, handleTolerance: 8),
                       .handle(t.id, .right))
        XCTAssertEqual(doc.resolvePointer(at: CGPoint(x: 20, y: 51), selection: t.id, bodyTolerance: 8, handleTolerance: 8),
                       .body(t.id), "top-left corner is no longer a handle")
    }
}
