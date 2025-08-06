# Development Reference

## Quick Start for New Sessions
- **Project**: Hello World Tools (HWT) - macOS SwiftUI app with AI tool calling
- **Current State**: ✅ **WORKING** - AI service with tools implemented and functioning correctly
- **Last Major Change**: Fixed JSX content generation and CSS class naming guidance
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
│   ├── OutputUbersichtWidget.swift  // Widget generation tool with JSX and file operations
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
- **Tool Integration**: ✅ **WORKING** - AI can invoke tools to generate widget artifacts

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
        // Tool implementation with JSX generation and file operations
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
- ✅ **Tools are working correctly** with `session.respond(to:)` (simple text responses)

### Session-Level Role Establishment
- **Instructions Parameter**: Role set via `LanguageModelSession(tools: instructions:)`
- **Natural Behavior**: AI responds naturally as widget designer when asked about purpose
- **Persistent Context**: Role maintained throughout entire session
- **No UI Required**: Role established automatically on first message
- **Tool Integration**: AI can invoke tools to generate widget artifacts

### Build commands

cd /Users/mike/Documents/ChatCore/ChatCore
xcodebuild -project "ChatCore.xcodeproj" -scheme "ChatCore" -configuration Debug build   

## Key Learning: Tool Invocation Works with Simple Text Responses

### What We Discovered
✅ **Tools work perfectly with `session.respond(to:)`** - structured generation is NOT required!

### The Real Issue Was
**Overly complex session instructions** that confused the AI about when and how to use tools.

### What Fixed It
1. **Removed complex numbered flow** (10, 20, 30) that was causing confusion
2. **Simplified instructions** to be direct and clear
3. **Added concrete examples** of when to use each tool
4. **Removed confusing logic** that made AI call tools multiple times

### Current Working Instructions
```
You are a widget designer. Create Übersicht widgets.

Tools:
- OutputUbersichtWidget: Creates widgets (bash, refresh, css, html, classes)
- TotalLengthOfStrings: Sums string lengths

Rules:
- Call each tool once per request
- DOM elements use className="name" → css_classes["name"]
- Data from bash command uses {data} in JSX

Example: "Create weather widget" → Use OutputUbersichtWidget
```

### Current Tools
- **OutputUbersichtWidget**: Generates Übersicht widget artifacts with JSX generation and file operations
- **TotalLengthOfStrings**: Calculates total length of string arrays

## Recent Enhancements

### File Operations Status: ✅ **WORKING**
- **JSX Generation**: ✅ **WORKING** - Uses string interpolation template
- **File Writing**: ✅ **WORKING** - Writing to correct Übersicht folder (App Sandbox disabled)
- **File Picker**: ✅ **WORKING** - System file picker with "first time prompt, then automatic save" behavior
- **Content Safety**: ✅ **WORKING** - Avoids FoundationModels blocking while preserving debug info

### App Sandbox Configuration
- **File System Entitlements Added**: User Selected File (Read/Write), Downloads Folder (Read/Write), File Bookmarks (App Scope)
- **App Sandbox Setting**: Set to FALSE to allow writing outside sandbox
- **Target Path**: `/Users/mike/Library/Application Support/Übersicht/widgets/`
- **Current Path**: `/Users/mike/Library/Application Support/Übersicht/widgets/` ✅ **WORKING**

### File Saving Architecture
- **FilePickerUtility**: Shared utility in ChatCore for system file picker functionality
- **Tool-Initiated Saving**: Tools directly call `FilePickerUtility.saveFile()` instead of relying on ChatViewModel detection
- **First-Time Behavior**: System file picker appears on first save to let user choose location
- **Subsequent Saves**: Automatic saves to the same location without re-prompting
- **Concurrency Safety**: `@MainActor` annotation ensures thread-safe shared state management

### Tool Invocation Discovery
- **Keyword Requirement**: AI requires "Übersicht widget" keyword to invoke tool
- **Literal Matching**: "Generate a widget" → ❌ No tool invoked
- **Exact Matching**: "Generate a Übersicht widget" → ✅ Tool invoked
- **Session Instructions**: Need to establish "widget" = "Übersicht widget" terminology

### FoundationModels Version Issue
- **Symbol Linking Error**: `dyld: Symbol not found: _$s16FoundationModels4ToolP4call9argumentsAA0C6OutputV9ArgumentsQz_tYaKFTq`
- **Cause**: Method signature mismatch between current FoundationModels version and tool implementation
- **Solution**: Update Xcode/macOS or adjust tool method signature
- **Current Method**: `func call(arguments: Arguments) async throws -> ToolOutput`
- **Possible Fix**: `func call(_ arguments: Arguments) async throws -> ToolOutput`

## Known Issues

### Resolved Issues
- ✅ **Tool invocation fixed**: Tools now work correctly with simple text responses
- ✅ **Complex instructions removed**: Simplified session instructions eliminate confusion
- ✅ **Tool name mismatches fixed**: All tool names now match between code and instructions
- ✅ **File system entitlements added**: App can now write files
- ✅ **File location problem resolved**: App Sandbox disabled to allow writing to correct Übersicht folder
- ✅ **File picker presentation fixed**: `NSSavePanel.beginSheetModal(for: window)` ensures proper system dialog display
- ✅ **Duplicate save dialogs eliminated**: ChatViewModel's tool detection disabled for HWT app
- ✅ **Concurrency safety implemented**: `@MainActor` annotation resolves shared state issues

### Current Issues
- ⚠️ **FoundationModels API compatibility**: Symbol linking error suggests version mismatch
- ⚠️ **Tool invocation requires specific keywords**: "Übersicht widget" needed for tool invocation
- ⚠️ **JSX generation**: AI sometimes generates plain text instead of proper JSX syntax
- ⚠️ **CSS class naming**: AI may use hyphens in class names causing JavaScript syntax errors

### Recent Changes Made
- **Tool Implementation**: Enhanced `OutputUbersichtWidget` with JSX generation and file operations
- **String Interpolation**: Added `generateUbersichtJSX()` function using your template
- **File Operations**: Added `writeJSXToDisk()` and `showFilePicker()` functions
- **Content Safety**: Modified tool output to avoid FoundationModels blocking while preserving debug info
- **App Sandbox**: Added file system entitlements for file writing capabilities
- **FilePickerUtility**: Created shared utility in ChatCore for system file picker functionality
- **ChatViewModel Enhancement**: Added `disableToolCallDetection` flag to prevent duplicate save dialogs
- **Concurrency Safety**: Implemented `@MainActor` annotation for thread-safe shared state management
- **JSX Content Fix**: Changed `htmlContent` argument to `jsxContent` with proper JSX description
- **Widget Definition**: Added comprehensive widget definition to `humanRolePrompt` explaining components
- **CSS Class Naming**: Added guidance for camelCase/underscore naming to avoid JavaScript syntax errors

### Current Status
- **Tool Registration**: ✅ Tools are properly registered in `ToolsEnabledAIService`
- **Session Creation**: ✅ Session created with tools and instructions
- **Tool Implementation**: ✅ Tools follow FoundationModels patterns with enhanced functionality
- **AI Instructions**: ✅ Session instructions are clear and effective
- **Tool Invocation**: ✅ Tools are being called correctly by AI (with proper keywords)
- **File Operations**: ✅ **WORKING** - Writing to correct Übersicht folder with proper file picker behavior

## Next Steps for Development
1. **Update FoundationModels**: Resolve symbol linking error with Xcode/macOS update
2. **Improve session instructions**: Add "widget" = "Übersicht widget" terminology
3. **Test widget creation**: Verify AI creates proper widgets with correct file locations
4. **Enhance widget capabilities**: Add more specialized tools for different widget types
5. **Improve error handling**: Add better error messages for tool failures
6. **Add debugging tools**: Create tools for testing and validation
7. **Improve output quality**: Work on enhancing the quality and reliability of the model's generated widget code
8. **Test JSX generation**: Verify AI generates proper JSX syntax instead of plain text
9. **Test CSS class naming**: Ensure AI uses camelCase/underscore naming conventions

## Future Enhancements
- Expand Shared components library
- Add Profile section views
- Implement additional AI features
- Enhance widget generation capabilities
- Add more specialized tools for widget design 