# Development Reference

## Quick Start for New Sessions
- **Project**: Hello World Tools (HWT) - macOS SwiftUI app with AI tool calling
- **Current State**: AI service with tools implemented, but `ToolSendWidgetToOutput` not being invoked
- **Last Major Change**: Converted tools to use `@Observable` classes with `@Generable` arguments
- **Key Files**: `ToolsEnabledAIService.swift`, `ToolSendWidgetToOutput.swift`, `Constants.swift`
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
│   ├── ToolSendWidgetToOutput.swift // Widget generation tool
│   └── ToolB.swift                  // Example tool
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
- **Structured Output**: Toggle for different AI response strategies
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
class ToolSendWidgetToOutput: Tool {
    @Guide("Generate Übersicht widget artifacts")
    func call(_ arguments: Arguments) async throws -> String {
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
- Supports structured output with multiple strategies
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

## Known Issues

### Tool Invocation Issues
- **ToolSendWidgetToOutput doesn't get invoked**: The tool is properly registered in `ToolsEnabledAIService` but may not be getting invoked by the AI. This could be due to:
  - AI not recognizing when to use the tool
  - Tool argument validation issues
  - Session instructions not clearly indicating tool usage
  - Tool name or description not matching AI expectations

### Recent Changes Made
- **Tool Implementation**: Converted from manual `GenerationSchema` creation to `@Observable` classes with `@Generable` argument structs
- **Argument Handling**: Changed `cssClasses` from `[String: String]` dictionary to JSON string due to `@Generable` limitations
- **Error Handling**: Added proper argument validation and custom error types in `ToolSendWidgetToOutput`
- **Session Instructions**: Enhanced `humanRolePrompt` in `Constants.swift` to describe available tools and their usage

### Current Debugging Status
- **Tool Registration**: ✅ Tools are properly registered in `ToolsEnabledAIService`
- **Session Creation**: ✅ Session created with tools and instructions
- **Tool Implementation**: ✅ Tools follow FoundationModels patterns
- **AI Instructions**: ✅ Session instructions describe tool usage
- **Missing**: Tool invocation by AI during conversation

## Next Steps for Development
1. **Debug Tool Invocation**: Test if AI recognizes when to use tools
2. **Verify Instructions**: Ensure session instructions clearly indicate tool usage scenarios
3. **Test Tool Arguments**: Verify argument parsing and validation works correctly
4. **Add Logging**: Add debug logging to track when tools are called vs. when they should be called

## Future Enhancements
- Expand Shared components library
- Add Profile section views
- Implement additional AI features
- Enhance widget generation capabilities
- Fix tool invocation issues
- Add more specialized tools for widget design 