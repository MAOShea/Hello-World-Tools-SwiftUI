# Development Reference

## Current Project
- **Framework**: SwiftUI for macOS
- **Language**: Swift
- **Platform**: macOS (not iOS)
- **AI Integration**: ✅ **Active** - Using Apple's FoundationModels framework
- **External Dependencies**: ChatCore library for chat functionality

## Key Dependencies

### External Libraries
- **ChatCore**: Custom library for chat functionality and UI components
  - Located at: `/Users/mike/Documents/ChatCore/ChatCore/ChatCore.xcodeproj`
  - Provides: `ChatViewModel`, `ChatBubble`, `AIServiceProtocol`
- **FoundationModels**: Apple's AI framework
  - Provides: `LanguageModelSession` for local AI interactions with session-level instructions

### Import Statements
```swift
import ChatCore           // ✅ Chat functionality
import FoundationModels   // ✅ Apple's AI framework
```

## Key Development Guidelines

### SwiftUI Development
- Use **SwiftUI** components and APIs, not UIKit
- Use **NSColor** for system colors (macOS)
- Use **SwiftUI Font system** (`.system(size:weight:)` not UIKit font methods)
- Target **macOS** platform specifically

### Common Mistakes to Avoid
- Mixing UIKit and SwiftUI APIs
- Using iOS-specific colors (`.systemBackground`)
- Using UIKit font methods (`.boldSystemFont`, `.italicSystemFont`)

## Current Project Structure

### Sources/
```
Sources/
├── App/
│   └── Hello_World_ToolsApp.swift
├── Services/
│   ├── BasicAIService.swift      // AI service with session instructions
│   └── Network/                  // (empty)
├── Views/
│   ├── Home/
│   │   └── ContentView.swift     // Main chat interface
│   └── Shared/                   // (empty)
├── Models/                       // (empty)
├── ViewModels/                   // (empty)
└── Utilities/
    ├── Constants.swift           // App constants and session instructions
    ├── Extensions.swift          // Swift extensions
    └── Examples.swift            // Example code
```

### Resources/
```
Resources/
└── Assets/
    └── Assets.xcassets/
        ├── AccentColor.colorset/
        ├── AppIcon.appiconset/
        └── Contents.json
```

## Current Features

### AI Chat Interface
- **Conversation History**: Persistent chat with local AI
- **Structured Output**: Toggle for different AI response strategies
- **Widget Generation**: AI-powered Übersicht widget creation
- **Real-time Interaction**: Live chat with loading states and error handling
- **Session-Level Role**: AI automatically assumes widget designer role

### UI Components
- **VSplitView**: Split interface with conversation history and input
- **ChatBubble**: Message display components (from ChatCore)
- **SaveWidgetView**: Modal for saving generated JavaScript widgets

## Quick Reference

### Colors
```swift
Color(NSColor.windowBackgroundColor)  // ✅ macOS
Color(NSColor.controlBackgroundColor) // ✅ macOS
Color.blue                            // ✅ SwiftUI
Color(.systemBackground)              // ❌ iOS only
```

### Fonts
```swift
.font(.system(size: 16, weight: .bold))  // ✅ SwiftUI
.font(.boldSystemFont(ofSize: 16))       // ❌ UIKit
```

### AI Service Usage
```swift
// Initialize AI service with session instructions
let aiService = BasicAIService()

// Send message to AI (role established via session instructions)
let response = await aiService.sendMessage("Hello AI")

// Handle loading and error states
@Published var isLoading: Bool
@Published var lastError: String?
```

### Session Instructions
```swift
// Session created with role instructions
session = LanguageModelSession(instruction: Constants.Prompts.humanRolePrompt)

// AI naturally assumes the specified role throughout the session
```

## Development Notes

### ChatCore Integration
- The ChatCore library provides the core chat functionality
- `ChatViewModel` manages conversation state and AI interactions
- `ChatBubble` components handle message display
- AI service protocol ensures consistent interface

### AI Implementation
- Uses Apple's `LanguageModelSession` with session-level instructions
- Role establishment via `LanguageModelSession(instruction: ...)` parameter
- AI naturally identifies as widget designer without UI prompts
- Supports structured output with multiple strategies
- Handles model availability and content safety errors
- Provides widget generation capabilities for Übersicht

### Session-Level Role Establishment
- **Instructions Parameter**: Role set via `LanguageModelSession(instruction: ...)`
- **Natural Behavior**: AI responds naturally as widget designer when asked about purpose
- **Persistent Context**: Role maintained throughout entire session
- **No UI Required**: Role established automatically on first message

### Build commands

cd /Users/mike/Documents/ChatCore/ChatCore
xcodebuild -project "ChatCore.xcodeproj" -scheme "ChatCore" -configuration Debug build   

### Future Enhancements
- Expand Shared components library
- Add Profile section views
- Implement additional AI features
- Enhance widget generation capabilities 