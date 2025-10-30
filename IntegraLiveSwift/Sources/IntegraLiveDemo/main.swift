/// IntegraLive Swift - Command Line Demo
///
/// This is a command-line demonstration of the Swift port architecture.
/// The full GUI application requires building with Xcode for SwiftUI support.

import Foundation
import IntegraLiveCore

// MARK: - Main Demo

@main
struct IntegraLiveDemo {
    static func main() async {
        print("╔═══════════════════════════════════════════════════════════╗")
        print("║        IntegraLive Swift - Proof of Concept Demo         ║")
        print("║                                                           ║")
        print("║  Native Swift port for macOS Apple Silicon               ║")
        print("╚═══════════════════════════════════════════════════════════╝\n")
        
        // Demonstrate the core architecture
        await runDemo()
    }
    
    static func runDemo() async {
        print("🚀 Starting IntegraLive session...")
        let sessionManager = SessionManager()
        
        do {
            try await sessionManager.startSession()
            print("✅ Session started successfully\n")
            
            // Create a new project
            print("📁 Creating new project...")
            sessionManager.newProject(named: "Demo Project")
            print("✅ Project created: \(sessionManager.currentProject?.name ?? "Unknown")\n")
            
            // Add scenes
            print("🎬 Adding scenes...")
            try sessionManager.addScene(named: "Introduction")
            try sessionManager.addScene(named: "Main Performance")
            try sessionManager.addScene(named: "Outro")
            
            if let project = sessionManager.currentProject {
                print("✅ Added \(project.scenes.count) scenes\n")
                
                // Display project structure
                print("📊 Project Structure:")
                print("   Project: \(project.name)")
                print("   Created: \(formatDate(project.createdDate))")
                print("   Scenes:")
                for (index, scene) in project.scenes.enumerated() {
                    print("     \(index + 1). \(scene.name)")
                    print("        - ID: \(scene.id.uuidString.prefix(8))...")
                    print("        - Blocks: \(scene.blocks.count)")
                }
                print()
                
                // Add blocks to a scene
                print("🔲 Adding blocks to 'Main Performance' scene...")
                if let mainScene = project.scenes.first(where: { $0.name == "Main Performance" }) {
                    try sessionManager.addBlock(to: mainScene, named: "Audio Input")
                    try sessionManager.addBlock(to: mainScene, named: "Reverb Effect")
                    try sessionManager.addBlock(to: mainScene, named: "Audio Output")
                    print("✅ Added \(mainScene.blocks.count) blocks\n")
                }
                
                // Demonstrate models
                print("🏗️  Creating module instance...")
                let reverbModule = ModuleInstance(
                    moduleDefinitionID: "integra.reverb",
                    name: "Studio Reverb"
                )
                reverbModule.parameters["roomSize"] = 0.7
                reverbModule.parameters["damping"] = 0.5
                reverbModule.parameters["wetDry"] = 0.3
                print("✅ Module created: \(reverbModule.name)")
                print("   Parameters: \(reverbModule.parameters)\n")
                
                // Demonstrate connections
                print("🔗 Creating connections...")
                let connection = Connection(
                    sourceBlockID: UUID(),
                    targetBlockID: UUID(),
                    sourceEndpoint: "audioOut",
                    targetEndpoint: "audioIn"
                )
                print("✅ Connection created:")
                print("   From: \(connection.sourceEndpoint)")
                print("   To: \(connection.targetEndpoint)\n")
                
                // Display summary
                print("📈 Session Summary:")
                print("   Status: \(sessionManager.statusMessage)")
                print("   Connected: \(sessionManager.isConnected ? "Yes" : "No")")
                print("   Total Scenes: \(project.scenes.count)")
                print("   Total Blocks: \(project.scenes.reduce(0) { $0 + $1.blocks.count })\n")
            }
            
            // End session
            print("🛑 Ending session...")
            await sessionManager.endSession()
            print("✅ Session ended\n")
            
            print("╔═══════════════════════════════════════════════════════════╗")
            print("║                 Demo Completed Successfully               ║")
            print("╚═══════════════════════════════════════════════════════════╝\n")
            
            print("ℹ️  This demonstrates the core architecture of the Swift port.")
            print("   To run the full GUI application:")
            print("   1. Open IntegraLiveSwift directory in Xcode")
            print("   2. Build and run the macOS target")
            print("   3. The SwiftUI interface will launch\n")
            
        } catch {
            print("❌ Error: \(error)\n")
        }
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
