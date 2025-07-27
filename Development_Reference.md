# Development Reference

## Quick Start for New Sessions
- **Project**: Hello World Tools (HWT) - macOS SwiftUI app with AI tool calling
- **Current State**: AI service with tools implemented, but tools not being invoked due to using simple text responses instead of structured generation
- **Last Major Change**: Identified that tools require structured generation (`session.streamResponse`) not simple text responses (`session.respond`)
- **Key Files**: `ToolsEnabledAIService.swift`, `OutputUbersichtWidget.swift`, `TotalLengthOfStrings.swift`, `Constants.swift`
- **Build**: Requires ChatCore library at `/Users/mike/Documents/ChatCore/ChatCore/ChatCore.xcodeproj`

## Current Project
- **Framework**: SwiftUI for macOS
- **Language**: Swift
- **Platform**: macOS (not iOS)
- **AI Integration**: ✅ **Active** - Using Apple's FoundationModels framework with tool calling
- **External Dependencies**: ChatCore library for chat functionality

## Key Dependencies

### External Libraries
- **ChatCore**: Custom library for chat functionality and UI components
  - Located at: `/Users/mike/Documents/ChatCore/ChatCore/ChatCore.xcodeproj`
  - Provides: `ChatViewModel`, `ChatBubble`, `AIServiceProtocol`
- **FoundationModels**: Apple's AI framework
  - Provides: `LanguageModelSession` for local AI interactions with session-level instructions and tool calling

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
│   └── ToolsEnabledAIService.swift  // AI service with tools and session instructions
├── Tools/
│   ├── OutputUbersichtWidget.swift  // Widget generation tool
│   └── TotalLengthOfStrings.swift   // String length calculation tool
├── Views/
│   ├── Home/
│   │   └── ContentView.swift        // Main chat interface
│   └── Shared/                      // (empty)
├── Models/                          // (empty)
├── ViewModels/                      // (empty)
└── Utilities/
    ├── Constants.swift              // App constants and session instructions
    ├── Extensions.swift             // Swift extensions
    └── Examples.swift               // Example code
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
- **Widget Generation**: AI-powered Übersicht widget creation with tool calling
- **Real-time Interaction**: Live chat with loading states and error handling
- **Session-Level Role**: AI automatically assumes widget designer role
- **Tool Integration**: AI can invoke tools to generate widget artifacts

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
// Initialize AI service with tools and session instructions
let aiService = ToolsEnabledAIService()

// Send message to AI (role established via session instructions)
let response = await aiService.sendMessage("Hello AI")

// Handle loading and error states
@Published var isLoading: Bool
@Published var lastError: String?
```

### Session Instructions
```swift
// Session created with tools and role instructions
session = LanguageModelSession(tools: tools) {
    Instructions {
        Constants.Prompts.humanRolePrompt
    }
}

// AI naturally assumes the specified role throughout the session
// AI can invoke tools when appropriate
```

### Tool Implementation
```swift
// Tools are @Observable classes with @Generable argument structs
@Observable
class OutputUbersichtWidget: Tool {
    @Guide("Generate Übersicht widget artifacts")
    func call(_ arguments: Arguments) async throws -> ToolOutput {
        // Tool implementation
    }
    
    @Generable
    struct Arguments {
        let bashCommand: String
        let refreshFrequency: Int
        let cssPositioning: String
        let htmlContent: String
        let classNameDictionary: String  // JSON string for CSS classes
    }
}
```

## Development Notes

### ChatCore Integration
- The ChatCore library provides the core chat functionality
- `ChatViewModel` manages conversation state and AI interactions
- `ChatBubble` components handle message display
- AI service protocol ensures consistent interface

### AI Implementation
- Uses Apple's `LanguageModelSession` with session-level instructions and tool calling
- Role establishment via `LanguageModelSession(tools: instructions:)` parameter
- AI naturally identifies as widget designer without UI prompts
- Handles model availability and content safety errors
- Provides widget generation capabilities for Übersicht via tool calling
- Tools are registered and available for AI invocation

### Session-Level Role Establishment
- **Instructions Parameter**: Role set via `LanguageModelSession(tools: instructions:)`
- **Natural Behavior**: AI responds naturally as widget designer when asked about purpose
- **Persistent Context**: Role maintained throughout entire session
- **No UI Required**: Role established automatically on first message
- **Tool Integration**: AI can invoke tools to generate widget artifacts

### Build commands

cd /Users/mike/Documents/ChatCore/ChatCore
xcodebuild -project "ChatCore.xcodeproj" -scheme "ChatCore" -configuration Debug build   

## Critical Issue: Tool Invocation Requires Structured Generation

### Problem Identified
Tools are not being invoked because the app uses **simple text responses** (`session.respond(to:)`) instead of **structured generation** (`session.streamResponse(generating: Schema.self, ...)`).

### Comparison with Sample App
**Sample App (FoundationModelsTripPlanner):**
```swift
// Uses structured generation
session.streamResponse(generating: Itinerary.self, ...) {
    "Generate a \(dayCount)-day itinerary to \(landmark.name)."
}
```

**Current App:**
```swift
// Uses simple text responses
session.respond(to: input)
```

### Why Structured Generation Works Better
1. **Clear Schema**: AI has a structured output format to follow
2. **Deliberate Process**: Generation is more methodical than conversation
3. **Tool Integration**: Tools are part of the structured generation process
4. **Forced Usage**: Schema requirements force tool invocation when needed

### Current Tools
- **OutputUbersichtWidget**: Generates Übersicht widget artifacts
- **TotalLengthOfStrings**: Calculates total length of string arrays

## Known Issues

### Tool Invocation Issues
- **Tools not being invoked**: Using `session.respond(to:)` instead of `session.streamResponse(generating:)`
- **Complex Instructions**: Session instructions are overly complex for simple text responses
- **Missing Structured Schema**: No clear output structure for AI to follow

### Recent Changes Made
- **Tool Implementation**: Converted to `@Observable` classes with `@Generable` argument structs
- **Argument Handling**: Changed `cssClasses` from `[String: String]` dictionary to JSON string due to `@Generable` limitations
- **Error Handling**: Added proper argument validation and custom error types
- **Tool Names**: Fixed tool name mismatches in session instructions

### Current Debugging Status
- **Tool Registration**: ✅ Tools are properly registered in `ToolsEnabledAIService`
- **Session Creation**: ✅ Session created with tools and instructions
- **Tool Implementation**: ✅ Tools follow FoundationModels patterns
- **AI Instructions**: ✅ Session instructions describe tool usage
- **Missing**: Structured generation approach for tool invocation

## Next Steps for Development
1. **Implement Structured Generation**: Create a `WidgetSchema` struct and use `session.streamResponse(generating: WidgetSchema.self, ...)`
2. **Simplify Instructions**: Reduce complexity of session instructions for structured generation
3. **Test Tool Invocation**: Verify tools are called during structured generation
4. **Add Debug Logging**: Track when tools are invoked vs. when they should be invoked

## Future Enhancements
- Expand Shared components library
- Add Profile section views
- Implement additional AI features
- Enhance widget generation capabilities
- Add more specialized tools for widget design 