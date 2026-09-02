# Kakico (Skitch-look fork)

Kakico is a native **Apple Silicon (arm64)** screenshot-annotation app for macOS, written in
Swift (SwiftUI shell + AppKit canvas, Core Graphics / Core Image rendering). It aims to be a
modern Skitch alternative.

This is [2b3pro](https://github.com/2b3pro)'s fork of
[tk3fftk/kakico](https://github.com/tk3fftk/kakico). It keeps the original's speed and
simplicity and brings the annotations closer to Skitch's look and feel: shadowed arrows and
shapes, haloed or outlined text, icon-pin stamps, a pen that doubles as a highlighter, and a
few navigation and memory conveniences. The changes have been offered upstream in
[tk3fftk/kakico#48](https://github.com/tk3fftk/kakico/issues/48).

## What it does

Open, paste, or drop an image, mark it up, and export (shortcuts in parentheses).

- **Tools:** Select (`V`), Arrow (`A`), Line (`L`), Rectangle (`R`), Ellipse (`O`), Pen (`D`),
  Text (`T`), Stamp (`S`), Pixelate (`P`), and Crop (`C`).
- **Skitch look:** arrows, lines, rectangles, and ellipses cast a soft drop shadow that scales
  with the stroke width and stays identical at every export size.
- **Text:** three styles, **Shadow** (white or black halo plus drop shadow), **Outline**, and
  **Plain**, chosen from the palette or by clicking the round "a" button above a selected text
  box, which previews the style you will get next. Side handles set the width and the text
  re-wraps; the bottom-right handle scales the font.
- **Stamps:** check, cross, exclamation, question, and heart as Skitch-style pins. Click to
  place; drag while placing to aim the tail; drag the tail later to re-aim; drag the disk edge
  to resize. Pick the glyph from the row that appears beside the Stamp tool.
- **Pen and highlighter:** freehand strokes with round caps. Lower the opacity to turn the pen
  into a highlighter. Shift-click twice to draw a straight line between two points.
- **Editing:** select, move, and resize via handles; Undo (`Cmd+Z`), Redo (`Cmd+Shift+Z`),
  Delete. Stroke color, width, pixel size, opacity, text style, and stamp glyph are remembered
  across launches, with sizes scaled to each image so they look the same on any screenshot.
- **Navigation:** zoom in and out (`Cmd++` / `Cmd+-`), fit to window (`Cmd+0`), pinch to zoom,
  `Cmd`+scroll wheel to zoom about the pointer, and hold `Space` and drag to pan when zoomed
  in.
- **Output:** export as PNG, JPEG, or lossy WebP (`Cmd+E`); copy to clipboard (`Cmd+Shift+C`);
  drag out as a PNG file.
- **Tabs:** new tab (`Cmd+T`), close tab (`Cmd+W`), previous and next tab (`Opt+Cmd+←/→`).
  Edit multiple images in separate tabs without losing work.

## Install

This fork is not distributed as a binary; build it from source (below). The original Kakico
is available from its author as a Homebrew cask (`brew tap tk3fftk/tap` then
`brew install --cask kakico`).

## Build & Run

```sh
swift test                       # Run unit tests (model, renderer, and app)
bash scripts/build-app.sh        # Build & assemble an ad-hoc-signed Kakico.app
open build/Kakico.app
```

Requirements: macOS 15+, Xcode/Swift toolchain. The build script produces a native arm64,
ad-hoc-signed bundle (no Apple Developer account required). The repository's lint hook uses
[SwiftLint](https://github.com/realm/SwiftLint) (`brew install swiftlint`).

## Project layout

- `Sources/AnnotationModel/` — pure value-type model (no AppKit or SwiftUI).
- `Sources/AnnotationRender/` — Core Graphics rendering of a `Document` into a `CGImage`,
  including the Skitch shadow, text styles, stamp pins, and pen strokes.
- `Sources/Kakico/` — the app: tabs, canvas, palette, export, and tool-state persistence.
- `Tests/` — unit tests for all three, including synthetic-event tests that drive the canvas
  view directly for gestures such as Shift-click lines, space-drag panning, and `Cmd`+scroll.

## License

This fork's contributions (everything added on top of
[tk3fftk/kakico](https://github.com/tk3fftk/kakico)) are released under the
MIT License; see [LICENSE](LICENSE). The original Kakico code is Copyright
Hiroki Takatsuka and has no license file at the time of writing, so it
remains all rights reserved until one is added upstream. Redistribution of
builds of this fork should wait for that.
