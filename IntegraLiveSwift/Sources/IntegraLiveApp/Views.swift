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

/// Detailed view of a scene with full editor functionality
struct SceneDetailView: View {
    let scene: Scene
    @State private var selectedBlock: Block?
    @State private var showingModuleLibrary = false
    @State private var canvasOffset: CGSize = .zero
    @State private var canvasScale: CGFloat = 1.0

    var body: some View {
        HSplitView {
            // Main Canvas Area
            SceneCanvasView(
                scene: scene,
                selectedBlock: $selectedBlock,
                offset: $canvasOffset,
                scale: $canvasScale
            )
            .frame(minWidth: 400)

            // Properties Panel (right sidebar)
            if let selectedBlock = selectedBlock {
                BlockPropertiesView(block: selectedBlock)
                    .frame(width: 280)
            } else {
                ScenePropertiesView(scene: scene)
                    .frame(width: 280)
            }
        }
        .navigationTitle(scene.name)
        .toolbar {
            SceneEditorToolbar(
                scene: scene,
                selectedBlock: $selectedBlock,
                showingModuleLibrary: $showingModuleLibrary,
                canvasOffset: $canvasOffset,
                canvasScale: $canvasScale
            )
        }
        .sheet(isPresented: $showingModuleLibrary) {
            ModuleLibraryView(scene: scene)
        }
    }
}

// MARK: - Scene Canvas View

/// Canvas for displaying and editing blocks and connections
struct SceneCanvasView: View {
    let scene: Scene
    @Binding var selectedBlock: Block?
    @Binding var offset: CGSize
    @Binding var scale: CGFloat
    @State private var draggedBlock: Block?
    @State private var isDraggingCanvas = false
    @State private var startDragPosition: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                CanvasGridView()

                // Connections layer
                ForEach(scene.blocks, id: \.id) { block in
                    ForEach(block.connections, id: \.id) { connection in
                        if let targetBlock = scene.blocks.first(where: { $0.id == connection.targetBlockID }) {
                            ConnectionLineView(
                                from: CGPoint(
                                    x: block.position.x + block.size.width,
                                    y: block.position.y + block.size.height / 2
                                ),
                                to: CGPoint(
                                    x: targetBlock.position.x,
                                    y: targetBlock.position.y + targetBlock.size.height / 2
                                )
                            )
                        }
                    }
                }

                // Blocks layer
                ForEach(scene.blocks, id: \.id) { block in
                    BlockView(
                        block: block,
                        isSelected: selectedBlock?.id == block.id
                    )
                    .position(
                        x: block.position.x + block.size.width / 2,
                        y: block.position.y + block.size.height / 2
                    )
                    .onTapGesture {
                        selectedBlock = block
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                block.position = CGPoint(
                                    x: value.location.x - block.size.width / 2,
                                    y: value.location.y - block.size.height / 2
                                )
                            }
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDraggingCanvas {
                            isDraggingCanvas = true
                            startDragPosition = value.location
                        }
                        offset = CGSize(
                            width: value.translation.width,
                            height: value.translation.height
                        )
                    }
                    .onEnded { _ in
                        isDraggingCanvas = false
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = min(max(value, 0.5), 2.0)
                    }
            )
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Canvas Grid View

/// Background grid for the canvas
struct CanvasGridView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 20

                // Vertical lines
                for x in stride(from: 0, through: geometry.size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }

                // Horizontal lines
                for y in stride(from: 0, through: geometry.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        }
    }
}

// MARK: - Block View

/// Visual representation of a block on the canvas
struct BlockView: View {
    @ObservedObject var block: Block
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            // Block header
            HStack {
                Image(systemName: block.moduleInstance != nil ? "waveform.circle.fill" : "cube.fill")
                    .foregroundColor(.white)
                    .font(.caption)

                Text(block.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Block body
            VStack(spacing: 2) {
                if let module = block.moduleInstance {
                    Text(module.moduleDefinitionID)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("No module")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }

                Text("\(block.connections.count) connections")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: block.size.width, height: block.size.height)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.2), radius: isSelected ? 4 : 2, x: 0, y: isSelected ? 2 : 1)
    }
}

// MARK: - Connection Line View

/// Visual representation of a connection between blocks
struct ConnectionLineView: View {
    let from: CGPoint
    let to: CGPoint

    var body: some View {
        Path { path in
            path.move(to: from)

            // Create a curved bezier path
            let controlPoint1 = CGPoint(x: from.x + (to.x - from.x) * 0.5, y: from.y)
            let controlPoint2 = CGPoint(x: from.x + (to.x - from.x) * 0.5, y: to.y)

            path.addCurve(to: to, control1: controlPoint1, control2: controlPoint2)
        }
        .stroke(Color.blue.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))

        // Arrow head at the end
        Path { path in
            let angle = atan2(to.y - from.y, to.x - from.x)
            let arrowLength: CGFloat = 8
            let arrowAngle: CGFloat = .pi / 6

            path.move(to: to)
            path.addLine(to: CGPoint(
                x: to.x - arrowLength * cos(angle - arrowAngle),
                y: to.y - arrowLength * sin(angle - arrowAngle)
            ))
            path.move(to: to)
            path.addLine(to: CGPoint(
                x: to.x - arrowLength * cos(angle + arrowAngle),
                y: to.y - arrowLength * sin(angle + arrowAngle)
            ))
        }
        .stroke(Color.blue.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

// MARK: - Block Properties View

/// Properties panel for a selected block
struct BlockPropertiesView: View {
    @ObservedObject var block: Block

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Block Properties")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)

                Divider()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Basic properties
                    GroupBox("Basic") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Name:")
                                    .frame(width: 60, alignment: .leading)
                                TextField("Block name", text: $block.name)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("ID:")
                                    .frame(width: 60, alignment: .leading)
                                Text(block.id.uuidString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(8)
                    }

                    // Module properties
                    if let module = block.moduleInstance {
                        GroupBox("Module") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Type:")
                                        .frame(width: 60, alignment: .leading)
                                    Text(module.moduleDefinitionID)
                                        .font(.caption)
                                }

                                HStack {
                                    Text("Name:")
                                        .frame(width: 60, alignment: .leading)
                                    Text(module.name)
                                        .font(.caption)
                                }

                                Divider()

                                Text("Parameters")
                                    .font(.caption)
                                    .fontWeight(.semibold)

                                if module.parameters.isEmpty {
                                    Text("No parameters")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .italic()
                                } else {
                                    ForEach(Array(module.parameters.keys), id: \.self) { key in
                                        ParameterControlView(
                                            name: key,
                                            value: String(describing: module.parameters[key] ?? "")
                                        )
                                    }
                                }
                            }
                            .padding(8)
                        }
                    }

                    // Connections
                    GroupBox("Connections") {
                        VStack(alignment: .leading, spacing: 4) {
                            if block.connections.isEmpty {
                                Text("No connections")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .padding(8)
                            } else {
                                ForEach(block.connections, id: \.id) { connection in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(connection.sourceEndpoint) → \(connection.targetEndpoint)")
                                            .font(.caption)
                                        Text("Target: \(connection.targetBlockID.uuidString)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(8)

                                    if connection.id != block.connections.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }

                    // Actions
                    GroupBox("Actions") {
                        VStack(spacing: 8) {
                            Button(action: {
                                // Add connection
                            }) {
                                Label("Add Connection", systemImage: "link.badge.plus")
                                    .frame(maxWidth: .infinity)
                            }

                            Button(action: {
                                // Delete block
                            }) {
                                Label("Delete Block", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundColor(.red)
                        }
                        .padding(8)
                    }
                }
                .padding()
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Parameter Control View

/// Control widget for a module parameter
struct ParameterControlView: View {
    let name: String
    let value: String
    @State private var sliderValue: Double = 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption2)
                    .fontWeight(.medium)
                Spacer()
                Text(value)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Slider(value: $sliderValue, in: 0...1)
                .controlSize(.small)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Scene Properties View

/// Properties panel when no block is selected
struct ScenePropertiesView: View {
    let scene: Scene

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Scene Properties")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)

                Divider()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GroupBox("Information") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Name:")
                                    .frame(width: 80, alignment: .leading)
                                Text(scene.name)
                            }

                            HStack {
                                Text("Blocks:")
                                    .frame(width: 80, alignment: .leading)
                                Text("\(scene.blocks.count)")
                            }

                            HStack {
                                Text("ID:")
                                    .frame(width: 80, alignment: .leading)
                                Text(scene.id.uuidString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .font(.caption)
                        .padding(8)
                    }

                    GroupBox("Quick Actions") {
                        VStack(spacing: 8) {
                            Button(action: {
                                // Add block
                            }) {
                                Label("Add Block", systemImage: "plus.square")
                                    .frame(maxWidth: .infinity)
                            }

                            Button(action: {
                                // Clear scene
                            }) {
                                Label("Clear Scene", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundColor(.red)
                        }
                        .padding(8)
                    }
                }
                .padding()
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Scene Editor Toolbar

/// Toolbar for the scene editor
struct SceneEditorToolbar: View {
    let scene: Scene
    @Binding var selectedBlock: Block?
    @Binding var showingModuleLibrary: Bool
    @Binding var canvasOffset: CGSize
    @Binding var canvasScale: CGFloat

    var body: some View {
        HStack {
            Button(action: {
                // Add new block at random position
                let newBlock = Block(
                    name: "Block \(scene.blocks.count + 1)",
                    position: CGPoint(x: Double.random(in: 100...400), y: Double.random(in: 100...400))
                )
                scene.blocks.append(newBlock)
            }) {
                Label("Add Block", systemImage: "plus.square")
            }
            .keyboardShortcut("b", modifiers: [.command])

            Button(action: {
                showingModuleLibrary = true
            }) {
                Label("Module Library", systemImage: "square.grid.2x2")
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])

            Divider()

            Button(action: {
                canvasOffset = .zero
                canvasScale = 1.0
            }) {
                Label("Reset View", systemImage: "arrow.clockwise")
            }
            .keyboardShortcut("0", modifiers: [.command])

            Button(action: {
                canvasScale = min(canvasScale + 0.1, 2.0)
            }) {
                Label("Zoom In", systemImage: "plus.magnifyingglass")
            }
            .keyboardShortcut("+", modifiers: [.command])

            Button(action: {
                canvasScale = max(canvasScale - 0.1, 0.5)
            }) {
                Label("Zoom Out", systemImage: "minus.magnifyingglass")
            }
            .keyboardShortcut("-", modifiers: [.command])

            Spacer()

            Text("\(Int(canvasScale * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Module Library View

/// Module library for selecting and adding modules
struct ModuleLibraryView: View {
    let scene: Scene
    @Environment(\.dismiss) private var dismiss

    let sampleModules = [
        ("audio.reverb", "Reverb", "Audio effect"),
        ("audio.delay", "Delay", "Audio effect"),
        ("audio.filter", "Filter", "Audio processor"),
        ("synth.oscillator", "Oscillator", "Sound generator"),
        ("midi.input", "MIDI Input", "MIDI device"),
        ("audio.output", "Audio Output", "Output device")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Module Library")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()

            Divider()

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search modules...", text: .constant(""))
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .padding()

            // Module list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(sampleModules, id: \.0) { module in
                        ModuleLibraryItemView(
                            moduleID: module.0,
                            name: module.1,
                            description: module.2,
                            scene: scene
                        )
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
    }
}

// MARK: - Module Library Item View

/// Individual module item in the library
struct ModuleLibraryItemView: View {
    let moduleID: String
    let name: String
    let description: String
    let scene: Scene
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(moduleID)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                let newBlock = Block(
                    name: name,
                    position: CGPoint(x: 200, y: 200)
                )
                newBlock.moduleInstance = ModuleInstance(
                    moduleDefinitionID: moduleID,
                    name: name
                )
                scene.blocks.append(newBlock)
                dismiss()
            }) {
                Label("Add", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
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
