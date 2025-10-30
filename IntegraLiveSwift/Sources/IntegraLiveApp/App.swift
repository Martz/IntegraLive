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
                // New project action
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Button("Open Project...") {
                // Open project action
            }
            .keyboardShortcut("o", modifiers: .command)
            
            Divider()
            
            Button("Save") {
                // Save action
            }
            .keyboardShortcut("s", modifiers: .command)
            
            Button("Save As...") {
                // Save as action
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
        }
        
        // Help menu additions
        CommandGroup(after: .help) {
            Button("IntegraLive Documentation") {
                if let url = URL(string: "https://www.integralive.org") {
                    NSWorkspace.shared.open(url)
                }
            }
            
            Divider()
            
            Button("About IntegraLive Swift") {
                // Show about dialog
            }
        }
    }
}
