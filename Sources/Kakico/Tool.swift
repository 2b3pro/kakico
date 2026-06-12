import Foundation

enum Tool: String, CaseIterable, Identifiable {
    case select
    case arrow
    case line
    case rectangle
    case ellipse
    case text
    case stamp
    case pixelate
    case blur
    case crop

    var id: String { rawValue }

    var label: String {
        switch self {
        case .select: return "Select"
        case .arrow: return "Arrow"
        case .line: return "Line"
        case .rectangle: return "Rectangle"
        case .ellipse: return "Ellipse"
        case .text: return "Text"
        case .stamp: return "Stamp"
        case .pixelate: return "Pixelate"
        case .blur: return "Blur"
        case .crop: return "Crop"
        }
    }

    /// SF Symbol name for the palette button.
    var symbol: String {
        switch self {
        case .select: return "cursorarrow"
        case .arrow: return "arrow.up.right"
        case .line: return "line.diagonal"
        case .rectangle: return "rectangle"
        case .ellipse: return "circle"
        case .text: return "textformat"
        case .stamp: return "checkmark.seal"
        case .pixelate: return "squareshape.split.3x3"
        case .blur: return "drop"
        case .crop: return "crop"
        }
    }
}
