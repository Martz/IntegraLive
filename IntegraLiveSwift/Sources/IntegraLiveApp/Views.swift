/// Main SwiftUI views for IntegraLive Swift port
///
/// This file contains the user interface components built with SwiftUI,
/// replacing the original Flex/ActionScript UI.

import SwiftUI

// MARK: - Main Application View

/// The main application view
/// Corresponds to IntegraLive.mxml in the original GUI
struct IntegraLiveView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var showingNewProjectSheet = false
    @State private var newProjectName = "Untitled Project"
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - Scene List
            SidebarView(sessionManager: sessionManager)
        } detail: {
            // Main Content Area
            if let project = sessionManager.currentProject {
                ProjectView(project: project, sessionManager: sessionManager)
            } else {
                WelcomeView(sessionManager: sessionManager)
            }
        }
        .navigationTitle("IntegraLive Swift")
        .toolbar {
            ToolbarView(
                sessionManager: sessionManager,
                showingNewProjectSheet: $showingNewProjectSheet
            )
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectSheet(
                projectName: $newProjectName,
                sessionManager: sessionManager,
                isPresented: $showingNewProjectSheet
            )
        }
        .task {
            do {
                try await sessionManager.startSession()
            } catch {
                print("Failed to start session: \(error)")
            }
        }
    }
}

// MARK: - Welcome View

/// Initial welcome screen shown when no project is loaded
struct WelcomeView: View {
    let sessionManager: SessionManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to IntegraLive")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("A modular audio framework for macOS")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            VStack(spacing: 12) {
                Button(action: {
                    sessionManager.newProject(named: "New Project")
                }) {
                    Label("New Project", systemImage: "doc.badge.plus")
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    // Load project action
                }) {
                    Label("Open Project", systemImage: "folder")
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            Text("Status: \(sessionManager.statusMessage)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Sidebar View

/// Sidebar showing project scenes
struct SidebarView: View {
    @ObservedObject var sessionManager: SessionManager
    
    var body: some View {
        List {
            if let project = sessionManager.currentProject {
                Section("Scenes") {
                    ForEach(project.scenes, id: \.id) { scene in
                        NavigationLink(destination: SceneDetailView(scene: scene)) {
                            Label(scene.name, systemImage: "music.note.list")
                        }
                    }
                }
            } else {
                Text("No project loaded")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Project")
        .frame(minWidth: 200)
    }
}

// MARK: - Project View

/// Main project workspace view
struct ProjectView: View {
    let project: Project
    @ObservedObject var sessionManager: SessionManager
    
    var body: some View {
        VStack {
            // Project header
            HStack {
                Text(project.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(project.scenes.count) scenes")
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            // Scenes grid
            if project.scenes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No scenes in this project")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        try? sessionManager.addScene(named: "New Scene")
                    }) {
                        Label("Add Scene", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 250))
                    ], spacing: 20) {
                        ForEach(project.scenes, id: \.id) { scene in
                            SceneCard(scene: scene)
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            // Status bar
            HStack {
                Circle()
                    .fill(sessionManager.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(sessionManager.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
        }
    }
}

// MARK: - Scene Card

/// Card view for a scene in the project
struct SceneCard: View {
    let scene: Scene
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundColor(.blue)
                Text(scene.name)
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            HStack {
                Text("\(scene.blocks.count) blocks")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Scene Detail View

/// Detailed view of a scene
struct SceneDetailView: View {
    let scene: Scene
    
    var body: some View {
        VStack {
            Text(scene.name)
                .font(.title)
            
            Text("\(scene.blocks.count) blocks")
                .foregroundColor(.secondary)
            
            // In the full implementation, this would show:
            // - Block connections
            // - Audio routing
            // - Module parameters
            // Similar to the original Flex views
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Toolbar View

/// Main toolbar buttons
struct ToolbarView: View {
    @ObservedObject var sessionManager: SessionManager
    @Binding var showingNewProjectSheet: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                showingNewProjectSheet = true
            }) {
                Label("New", systemImage: "doc.badge.plus")
            }
            
            Button(action: {
                // Open project
            }) {
                Label("Open", systemImage: "folder")
            }
            
            Button(action: {
                // Save project
            }) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(sessionManager.currentProject == nil)
        }
    }
}

// MARK: - New Project Sheet

/// Sheet for creating a new project
struct NewProjectSheet: View {
    @Binding var projectName: String
    let sessionManager: SessionManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Project")
                .font(.title)
            
            TextField("Project Name", text: $projectName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Button("Create") {
                    sessionManager.newProject(named: projectName)
                    isPresented = false
                    projectName = "Untitled Project"
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
    }
}
