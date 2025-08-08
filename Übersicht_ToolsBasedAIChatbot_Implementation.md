# Tools-Based AI Chatbot Implementation

## Project Overview
**Hello World Tools (HWT)** - macOS SwiftUI app with AI tool calling using Apple's FoundationModels framework.

### Version History
**Übersicht Designer AI Chatbot v2.2** - This version introduces FoundationModels tool calling capabilities to enable non-coders to create Übersicht widgets through natural language conversation.

- **v1.0**: SDK for developing Übersicht widgets (code-based approach)
- **v2.0**: AI chatbot interface for non-coders to create widgets
- **v2.2**: Enhanced with FoundationModels tool calling for improved widget generation capabilities

## Core Architecture

### Key Components
- **AI Service**: `ToolsEnabledAIService.swift` - Manages FoundationModels session with tools
- **Tools**: `OutputUbersichtWidget.swift`, `TotalLengthOfStrings.swift` - AI-invokable functions
- **UI**: SwiftUI interface with ChatCore library integration
- **Framework**: FoundationModels for local AI with tool calling

### Dependencies
```swift
import FoundationModels   // Apple's AI framework with tool calling
import ChatCore          // Custom chat UI components
import SwiftUI           // macOS UI framework
```

### Implementation Status

#### ✅ Working Components
- **AI Service**: FoundationModels session with tools and session instructions
- **Tool Registration**: Tools are registered in `ToolsEnabledAIService`
- **Tool Invocation**: AI reliably invokes tools with proper keywords
- **File Operations**: Can write to Übersicht widgets folder using system file picker
- **Session Instructions**: LanguageModelSession establishes role and tool contracts

#### ⚠️ Current Issues (now improved!)
- **Keyword Requirement**: AI still requires "Übersicht widget" terminology for tool invocation
- **JSX Content**: Some AI generations include function wrappers or `return`; resolved by instructing the model to output only JSX markup
- **CSS Class Naming**: Former issue with hyphens/class names now resolved—model always uses variable names ending in `Style` and references with `{variable}` in JSX
## Tool Implementation

### OutputUbersichtWidget Tool — Contract

**Arguments:**
- `bashCommand` (String):  
  Bash command to be executed. If the command contains double quotes, escape them as `\"`.
- `refreshFrequency` (Int):  
  Widget refresh frequency in milliseconds.
- `cssPositioning` (String):  
  CSS positioning, in standard CSS format.
- `jsxContent` (String):  
  The JSX markup for the widget. Provide only the JSX elements for the function body; do not include a function declaration, curly braces, or `return`.
- `classNameDictionary` (String):  
  JSON dictionary where each key is a style variable name ending with `Style` (e.g., `"outputDivStyle"`), and each value is an Emotion-style CSS string.

**Rules:**
- Each style variable must end with `Style` and be referenced in JSX as `className={outputDivStyle}`.
- Do **not** use string literal class names (e.g., `className="outputDiv"`) or hyphens in variable names; use camelCase or underscores.
- Every variable used in JSX must have a matching entry in `classNameDictionary`.
- Only provide the JSX markup (no function wrappers).

**Example:**

```json
"classNameDictionary": {
  "outputDivStyle": "padding: 10px; color: red;",
  "titleStyle": "font-weight: bold;"
}
```

### TotalLengthOfStrings Tool — Contract

**Arguments:**
- `strings` ([String]):  
  An array of strings whose combined character length will be calculated.

**Behavior:**
- Returns the total length (number of characters) of all the strings in the array, summed together as an integer.

**Example:**

Input:
```json
"strings": ["hello", "world", "!"]
```

## Session Configuration

### AI Role Establishment
```swift
let session = LanguageModelSession(tools: tools) {
    Instructions {
        Constants.Prompts.humanRolePrompt
    }
}
```

### Session Instructions
```
You are a widget designer. Create Übersicht widgets.

Tools:
- OutputUbersichtWidget: Creates widgets (bash, refresh, css, html, classes)
- TotalLengthOfStrings: Sums string lengths

Rules:
- Call each tool once per request
- DOM elements use className="name" → css_classes["name"]
- Data from bash command uses {data} in JSX
```

## File Operations

### Übersicht Widget Generation
- **Target Path**: `/Users/mike/Library/Application Support/Übersicht/widgets/`
- **File Format**: JSX with Emotion CSS classes
- **File Picker**: System file picker with "first time prompt, then automatic save"
- **App Sandbox**: Disabled to allow writing outside sandbox

### JSX Template
```javascript
const { data } = require("sdk");
const { css } = require("emotion");

const styles = {
  // CSS classes from classNameDictionary
};

const widget = () => {
  return (
    <div className={css(styles.outputDiv)}>
      {/* JSX content from arguments */}
    </div>
  );
};

module.exports = widget;
```

## Development Guidelines

### SwiftUI Development
- Use **SwiftUI** components and APIs, not UIKit
- Use **NSColor** for system colors (macOS)
- Use **SwiftUI Font system** (`.system(size:weight:)`)

### FoundationModels Integration
- **Session Creation**: Use `LanguageModelSession(tools: instructions:)`
- **Tool Implementation**: Follow `@Observable` class with `@Generable` arguments
- **Error Handling**: Handle `LanguageModelSession.GenerationError` cases
- **Content Safety**: Avoid FoundationModels blocking while preserving debug info

## Testing and Debugging

### Xcode 26 Beta 5 Playgrounds
- **FoundationModels Feedback**: New feature for reporting framework issues directly from Playgrounds
- **Isolated Testing**: Test tools without app complexity
- **Rapid Iteration**: Instant code execution and results
- **API Testing**: Verify FoundationModels functionality in isolation

### Debugging Approaches
- **Playgrounds**: For framework-level testing and API exploration
- **App Debugging**: For full app testing, UI issues, and integration problems

## Next Implementation Steps

1. **Refine Tool Invocation**: Continue refining prompt so “widget” is always interpreted as “Übersicht widget,” ensuring consistent tool invocation.
2. **Enforce JSX Content Rules**: Further reinforce that AI-generated `jsx_content` must be JSX markup only—no function wrappers, no `return`, and no extraneous syntax.
3. **Solidify Style Variable Contracts**: Ensure the AI always outputs style variable names ending in `Style`, references them as `className={variable}` in JSX, and matches all such variables in the style dictionary.
4. **Playground & Integration Testing**: Use Xcode Playgrounds and app integration to validate proper tool output and UI rendering.
5. **Tool Expansion**: Consider adding more specialized tools for other widget or design types as needed.
6. **Continue Improving Error Handling**: Expand error messages and diagnostics for tool failures and output validation.

## Build Requirements

### External Dependencies
- **ChatCore**: Custom library at `/Users/mike/Documents/ChatCore/ChatCore/ChatCore.xcodeproj`
- **FoundationModels**: Apple's AI framework (System/Library/Frameworks/FoundationModels.framework)

### Build Commands
```bash
cd /Users/mike/Documents/ChatCore/ChatCore
xcodebuild -project "ChatCore.xcodeproj" -scheme "ChatCore" -configuration Debug build
``` 