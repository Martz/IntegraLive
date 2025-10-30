# Building the GUI Application with Xcode

The IntegraLive Swift proof of concept includes a SwiftUI-based GUI application that requires Xcode to build and run.

## Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Apple Silicon Mac (M1/M2/M3) or Intel Mac

## Opening in Xcode

1. Open Xcode
2. Choose "Open a project or file"
3. Navigate to the `IntegraLiveSwift` directory
4. Select `Package.swift`
5. Xcode will open the Swift Package

## Creating a macOS App Target

Since SwiftUI apps require an actual macOS application bundle, you need to create an app target:

### Option 1: Using Xcode GUI

1. In Xcode, go to File → New → Target
2. Choose "macOS" → "App"
3. Name it "IntegraLive"
4. Set the interface to "SwiftUI"
5. Set the language to "Swift"
6. Click "Finish"

### Option 2: Add files to new app

1. Create a new macOS app project in Xcode
2. Add the files from `Sources/IntegraLiveApp/` to the new project:
   - `App.swift` (contains the SwiftUI app entry point)
   - `Views.swift` (contains all SwiftUI views)
3. Add the `IntegraLiveCore` library as a dependency:
   - Select your app target
   - Go to "General" → "Frameworks and Libraries"
   - Click "+" and add `IntegraLiveCore`

## Quick Start App Structure

For a quick GUI test, here's a minimal macOS app setup:

### File: `IntegraLiveApp.swift`

```swift
import SwiftUI

@main
struct IntegraLiveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### File: `ContentView.swift`

```swift
import SwiftUI
import IntegraLiveCore

struct ContentView: View {
    @State private var sessionManager = SessionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("IntegraLive Swift")
                .font(.largeTitle)
            
            Button("Create New Project") {
                sessionManager.newProject(named: "New Project")
            }
            
            if let project = sessionManager.currentProject {
                Text("Current Project: \(project.name)")
                Text("Scenes: \(project.scenes.count)")
            }
        }
        .padding()
        .task {
            try? await sessionManager.startSession()
        }
    }
}
```

## Building and Running

1. Select the "IntegraLive" scheme in the toolbar
2. Choose your Mac as the destination
3. Click the "Run" button (or press ⌘R)
4. The app will build and launch

## Architecture Overview

The Swift port uses a clean separation of concerns:

```
IntegraLiveCore (Library)
├── Models.swift           - Data models
└── SessionManager.swift   - Business logic

IntegraLiveApp (macOS App)
├── App.swift             - App entry point
└── Views.swift           - SwiftUI interface

IntegraLiveDemo (CLI)
└── main.swift            - Command-line demo
```

## SwiftUI Preview

To see live previews in Xcode, add preview providers to your views:

```swift
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
```

## Troubleshooting

### "No such module 'IntegraLiveCore'"

Make sure the `IntegraLiveCore` library is added as a dependency to your app target.

### SwiftUI not available

SwiftUI requires macOS 10.15 or later. The package is configured for macOS 13.0 to use the latest features.

### Build errors with @Published

The command-line library doesn't use `@Published`. For SwiftUI apps, you can create a wrapper:

```swift
import SwiftUI
import IntegraLiveCore

class SessionManagerObservable: ObservableObject {
    @Published var sessionManager: SessionManager
    
    init() {
        sessionManager = SessionManager()
    }
}
```

## Next Steps

1. Review the code in `Sources/IntegraLiveApp/Views.swift`
2. Explore the demo by running: `swift run integra-demo`
3. Read the main README for the complete migration plan
4. Check the tests: `swift test`

## Resources

- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode/)
