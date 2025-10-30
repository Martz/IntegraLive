# IntegraLive Swift - Proof of Concept

A native Swift port of IntegraLive for macOS Apple Silicon, demonstrating the architecture and structure for migrating from the original ActionScript/Flex + C++ implementation.

## Overview

This proof of concept demonstrates a complete Swift-based architecture for IntegraLive that can run natively on Apple Silicon Macs. It provides a foundation for migrating all application functionality from the original implementation.

### Original Architecture

- **GUI**: Adobe Flex/ActionScript (333 files)
  - Built with MXML and ActionScript
  - Complex UI with scene management, module controls, and audio routing
- **Server**: C++ server application (`integra_server`)
  - Exposes XMLRPC interface
  - Manages audio/MIDI processing
- **libIntegra**: C++ library
  - Pure Data integration (libpd)
  - PortAudio for audio I/O
  - PortMIDI for MIDI support

### Swift POC Architecture

```
IntegraLiveSwift/
├── Package.swift                    # Swift Package Manager configuration
├── Sources/
│   └── IntegraLiveSwift/
│       ├── main.swift               # Application entry point
│       ├── Models.swift             # Core data models
│       ├── SessionManager.swift     # Session and backend communication
│       └── Views.swift              # SwiftUI user interface
└── Tests/
    └── IntegraLiveSwiftTests/
        └── IntegraLiveSwiftTests.swift  # Unit tests
```

## Key Components

### 1. Data Models (`Models.swift`)

Swift representations of the core domain objects:

- **Project**: Top-level container for an IntegraLive project
- **Scene**: A scene within a project containing blocks
- **Block**: An audio/processing module instance
- **ModuleInstance**: Reference to a module with parameters
- **Connection**: Audio/control connections between blocks
- **InterfaceDefinition**: Module interface specifications
- **EndpointDefinition**: Module parameters and I/O

These correspond to the original ActionScript models:
- `Project.as` → `Project`
- `Scene.as` → `Scene`
- `Block.as` → `Block`
- `ModuleInstance.as` → `ModuleInstance`
- `Connection.as` → `Connection`

### 2. Session Management (`SessionManager.swift`)

Manages the application lifecycle and backend communication:

- **SessionManager**: Main controller (replaces `IntegraController.as`)
  - Project lifecycle management
  - Scene and block management
  - State management with SwiftUI's `@Published` properties

- **BackendCommunicator**: Communication layer
  - Prepares for XMLRPC integration with C++ server
  - Can be extended to call native Swift audio processing

Corresponds to:
- `IntegraController.as` → `SessionManager`
- `RemoteCommandHandler.as` → `BackendCommunicator`

### 3. User Interface (`Views.swift`)

Native SwiftUI views replacing the Flex UI:

- **IntegraLiveView**: Main application window
- **WelcomeView**: Initial screen
- **ProjectView**: Project workspace
- **SidebarView**: Scene navigation
- **SceneDetailView**: Scene editor (stub for future development)

Built with modern SwiftUI patterns:
- Declarative UI
- Reactive data binding
- Native macOS controls
- Optimized for Apple Silicon

### 4. Tests

Comprehensive unit tests covering:
- Model creation and manipulation
- Session management
- Project operations
- Error handling

## Building and Running

### Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Build

```bash
cd IntegraLiveSwift
swift build
```

### Run

```bash
swift run
```

### Test

```bash
swift test
```

## Migration Path

This POC establishes the foundation for a complete migration:

### Phase 1: Core Application (This POC)
- ✅ Swift project structure with SPM
- ✅ Core data models
- ✅ Session management architecture
- ✅ Basic SwiftUI interface
- ✅ Unit tests

### Phase 2: Enhanced UI
- [ ] Complete scene editor UI
- [ ] Block connection visualization
- [ ] Module parameter controls
- [ ] Audio routing display
- [ ] Drag-and-drop block creation
- [ ] Menu system completion

### Phase 3: Backend Integration
- [ ] XMLRPC client for C++ server communication
- [ ] OSC client for real-time updates
- [ ] File format compatibility (.integra files)
- [ ] Module loading and management

### Phase 4: Native Audio Processing
- [ ] Port libIntegra to Swift or create Swift wrapper
- [ ] Integrate AudioKit or AVFoundation for audio I/O
- [ ] MIDI support with CoreMIDI
- [ ] Pure Data integration options:
  - Option A: Keep libpd with C++ bridge
  - Option B: Explore native Swift alternatives

### Phase 5: Feature Parity
- [ ] All module types supported
- [ ] Complete parameter system
- [ ] Scene playback and recording
- [ ] MIDI control mapping
- [ ] Preferences and settings
- [ ] Module creator tools

### Phase 6: Enhanced Features
- [ ] Apple Silicon optimizations
- [ ] Native macOS integrations
- [ ] iCloud project sync
- [ ] Enhanced performance
- [ ] Modern UI/UX improvements

## Key Advantages of Swift Port

1. **Native Performance**: Optimized for Apple Silicon
2. **Modern UI**: SwiftUI provides native look and feel
3. **Safety**: Swift's type safety and memory management
4. **Maintainability**: Single language for the entire stack
5. **Future-Proof**: Built on Apple's current platform
6. **Integration**: Easy access to macOS APIs and frameworks
7. **Development Speed**: Faster iteration with SwiftUI previews

## Design Decisions

### Why SwiftUI?
- Modern, declarative UI framework
- Excellent performance on Apple Silicon
- Native macOS look and feel
- Reactive data flow with Combine
- Built-in accessibility support

### Why Swift Package Manager?
- Native Swift tooling
- Simple dependency management
- Easy to integrate with Xcode
- Good for modular architecture

### Backward Compatibility
The POC is designed to:
- Support existing .integra file formats (future work)
- Communicate with existing C++ server initially
- Provide migration path for existing projects
- Allow gradual migration of components

## Current Limitations

This is a proof of concept demonstrating architecture. Not yet implemented:
- Audio processing (requires libIntegra integration)
- MIDI support
- Module loading
- File I/O for project files
- Connection visualization
- Real-time audio routing

## Next Steps

1. **Review and Validate**: Ensure architecture meets requirements
2. **Backend Communication**: Implement XMLRPC client
3. **File Format**: Add .integra file reading/writing
4. **UI Enhancement**: Build out the scene editor
5. **Audio Integration**: Start porting or wrapping libIntegra

## Contributing

This POC establishes patterns and structure. When implementing features:
- Follow the established architecture
- Add tests for new functionality
- Use Swift best practices
- Document complex logic
- Maintain compatibility considerations

## License

This port maintains the original GPL-2.0 license of IntegraLive.

Copyright (C) 2007-2025 Birmingham City University

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

## References

- Original IntegraLive: https://www.integralive.org
- Swift Documentation: https://swift.org/documentation/
- SwiftUI Documentation: https://developer.apple.com/documentation/swiftui/
