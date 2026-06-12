import SwiftUI
import AppKit

@main
struct SnapmarkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var controller = CanvasController()

    var body: some Scene {
        Window("Snapmark", id: "main") {
            ContentView(controller: controller)
                .frame(minWidth: 720, minHeight: 520)
        }
        .commands { AppCommands(controller: controller) }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

struct AppCommands: Commands {
    @ObservedObject var controller: CanvasController

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Open Image…") { ExportService.openPanel(controller) }
                .keyboardShortcut("o", modifiers: .command)
            Button("Open Snapmark Document…") { ExportService.openDocument(controller) }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            // ⇧⌘V — plain ⌘V must stay free for Edit ▸ Paste (inline text editing).
            Button("Paste Image") { _ = controller.pasteImage() }
                .keyboardShortcut("v", modifiers: [.command, .shift])
        }
        CommandGroup(replacing: .saveItem) {
            Button("Save Snapmark Document…") { ExportService.saveDocument(controller) }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(!controller.hasDocument)
            Button("Export Image…") { ExportService.exportPanel(controller) }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(!controller.hasDocument)
            Button("Copy Image to Clipboard") { ExportService.copyToClipboard(controller) }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .disabled(!controller.hasDocument)
        }
        CommandGroup(replacing: .undoRedo) {
            Button("Undo") { controller.undo() }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(!controller.canUndo)
            Button("Redo") { controller.redo() }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(!controller.canRedo)
        }
        CommandMenu("Tools") {
            ForEach(Array(Tool.allCases.enumerated()), id: \.element.id) { index, tool in
                Button(tool.label) { controller.tool = tool }
                    .keyboardShortcut(KeyEquivalent(Character("\(index)")), modifiers: [])
            }
        }
    }
}
