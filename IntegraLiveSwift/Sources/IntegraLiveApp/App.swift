/// IntegraLive Swift - Main Entry Point
///
/// Proof of concept Swift port of IntegraLive for macOS Apple Silicon
/// This demonstrates the architecture and structure for a complete migration
/// from the original ActionScript/Flex + C++ implementation to native Swift.

import SwiftUI

@main
struct IntegraLiveApp: App {
    var body: some Scene {
        WindowGroup {
            IntegraLiveView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            IntegraLiveCommands()
        }
    }
}

// MARK: - Application Commands

/// Application menu commands
struct IntegraLiveCommands: Commands {
    var body: some Commands {
        // File menu
        CommandGroup(replacing: .newItem) {
            Button("New Project") {
                NotificationCenter.default.post(name: .newProject, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("Open Project...") {
                NotificationCenter.default.post(name: .openProject, object: nil)
            }
            .keyboardShortcut("o", modifiers: .command)

            Divider()

            Button("Save") {
                NotificationCenter.default.post(name: .saveProject, object: nil)
            }
            .keyboardShortcut("s", modifiers: .command)

            Button("Save As...") {
                NotificationCenter.default.post(name: .saveProjectAs, object: nil)
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])

            Divider()

            Button("Export...") {
                NotificationCenter.default.post(name: .exportProject, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
        }

        // Edit menu additions
        CommandGroup(after: .pasteboard) {
            Divider()

            Button("Delete") {
                NotificationCenter.default.post(name: .deleteSelection, object: nil)
            }
            .keyboardShortcut(.delete, modifiers: [])

            Button("Duplicate") {
                NotificationCenter.default.post(name: .duplicate, object: nil)
            }
            .keyboardShortcut("d", modifiers: .command)
        }

        // Scene menu
        CommandMenu("Scene") {
            Button("Add New Scene") {
                NotificationCenter.default.post(name: .addScene, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Button("Rename Scene") {
                NotificationCenter.default.post(name: .renameScene, object: nil)
            }
            .keyboardShortcut("r", modifiers: [.command])

            Button("Delete Scene") {
                NotificationCenter.default.post(name: .deleteScene, object: nil)
            }
            .keyboardShortcut(.delete, modifiers: [.command])

            Divider()

            Button("Clear All Blocks") {
                NotificationCenter.default.post(name: .clearScene, object: nil)
            }
        }

        // Block menu
        CommandMenu("Block") {
            Button("Add Block") {
                NotificationCenter.default.post(name: .addBlock, object: nil)
            }
            .keyboardShortcut("b", modifiers: .command)

            Button("Delete Block") {
                NotificationCenter.default.post(name: .deleteBlock, object: nil)
            }
            .keyboardShortcut("backspace", modifiers: .command)

            Divider()

            Button("Add Connection") {
                NotificationCenter.default.post(name: .addConnection, object: nil)
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])

            Button("Remove Connection") {
                NotificationCenter.default.post(name: .removeConnection, object: nil)
            }

            Divider()

            Button("Align Horizontally") {
                NotificationCenter.default.post(name: .alignHorizontally, object: nil)
            }

            Button("Align Vertically") {
                NotificationCenter.default.post(name: .alignVertically, object: nil)
            }

            Button("Distribute Horizontally") {
                NotificationCenter.default.post(name: .distributeHorizontally, object: nil)
            }

            Button("Distribute Vertically") {
                NotificationCenter.default.post(name: .distributeVertically, object: nil)
            }
        }

        // Module menu
        CommandMenu("Module") {
            Button("Open Module Library") {
                NotificationCenter.default.post(name: .openModuleLibrary, object: nil)
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])

            Divider()

            Button("Assign Module to Block") {
                NotificationCenter.default.post(name: .assignModule, object: nil)
            }
            .keyboardShortcut("m", modifiers: .command)

            Button("Remove Module from Block") {
                NotificationCenter.default.post(name: .removeModule, object: nil)
            }

            Divider()

            Button("Edit Module Parameters") {
                NotificationCenter.default.post(name: .editParameters, object: nil)
            }
            .keyboardShortcut("p", modifiers: .command)
        }

        // View menu
        CommandMenu("View") {
            Button("Zoom In") {
                NotificationCenter.default.post(name: .zoomIn, object: nil)
            }
            .keyboardShortcut("+", modifiers: .command)

            Button("Zoom Out") {
                NotificationCenter.default.post(name: .zoomOut, object: nil)
            }
            .keyboardShortcut("-", modifiers: .command)

            Button("Reset Zoom") {
                NotificationCenter.default.post(name: .resetZoom, object: nil)
            }
            .keyboardShortcut("0", modifiers: .command)

            Divider()

            Button("Fit to Window") {
                NotificationCenter.default.post(name: .fitToWindow, object: nil)
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])

            Divider()

            Button("Show Grid") {
                NotificationCenter.default.post(name: .toggleGrid, object: nil)
            }
            .keyboardShortcut("g", modifiers: .command)

            Button("Snap to Grid") {
                NotificationCenter.default.post(name: .toggleSnapToGrid, object: nil)
            }
        }

        // Help menu additions
        CommandGroup(after: .help) {
            Button("IntegraLive Documentation") {
                if let url = URL(string: "https://www.integralive.org") {
                    NSWorkspace.shared.open(url)
                }
            }

            Button("Module Development Guide") {
                if let url = URL(string: "https://www.integralive.org/documentation") {
                    NSWorkspace.shared.open(url)
                }
            }

            Divider()

            Button("Report Issue") {
                if let url = URL(string: "https://github.com/integralive/integralive/issues") {
                    NSWorkspace.shared.open(url)
                }
            }

            Divider()

            Button("About IntegraLive Swift") {
                NotificationCenter.default.post(name: .showAbout, object: nil)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    // File operations
    static let newProject = Notification.Name("newProject")
    static let openProject = Notification.Name("openProject")
    static let saveProject = Notification.Name("saveProject")
    static let saveProjectAs = Notification.Name("saveProjectAs")
    static let exportProject = Notification.Name("exportProject")

    // Edit operations
    static let deleteSelection = Notification.Name("deleteSelection")
    static let duplicate = Notification.Name("duplicate")

    // Scene operations
    static let addScene = Notification.Name("addScene")
    static let renameScene = Notification.Name("renameScene")
    static let deleteScene = Notification.Name("deleteScene")
    static let clearScene = Notification.Name("clearScene")

    // Block operations
    static let addBlock = Notification.Name("addBlock")
    static let deleteBlock = Notification.Name("deleteBlock")
    static let addConnection = Notification.Name("addConnection")
    static let removeConnection = Notification.Name("removeConnection")
    static let alignHorizontally = Notification.Name("alignHorizontally")
    static let alignVertically = Notification.Name("alignVertically")
    static let distributeHorizontally = Notification.Name("distributeHorizontally")
    static let distributeVertically = Notification.Name("distributeVertically")

    // Module operations
    static let openModuleLibrary = Notification.Name("openModuleLibrary")
    static let assignModule = Notification.Name("assignModule")
    static let removeModule = Notification.Name("removeModule")
    static let editParameters = Notification.Name("editParameters")

    // View operations
    static let zoomIn = Notification.Name("zoomIn")
    static let zoomOut = Notification.Name("zoomOut")
    static let resetZoom = Notification.Name("resetZoom")
    static let fitToWindow = Notification.Name("fitToWindow")
    static let toggleGrid = Notification.Name("toggleGrid")
    static let toggleSnapToGrid = Notification.Name("toggleSnapToGrid")

    // Other
    static let showAbout = Notification.Name("showAbout")
}
