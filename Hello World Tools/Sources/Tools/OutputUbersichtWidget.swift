//
//  ToolA.swift
//  Hello World Tools
//
//  Created by mike on 15/07/2025.
//

import Foundation
import FoundationModels
import SwiftUI
import UniformTypeIdentifiers
import ChatCore

final class OutputUbersichtWidget: Tool {
    let name = "OutputUbersichtWidget"
    let description = "Sends a Übersicht widget's properties to an output and returns a success confirmation message."
    
    @Generable
    struct Arguments: Codable {
        @Guide(description: """
        A bash command that will be executed later.
        """)
        let bashCommand: String

        @Guide(description: "The widget's refresh frequency in milliseconds.")
        let refreshFrequency: Int
        
        @Guide(description: """
        The widget's JSX content. Each DOM element can contain a className attribute.
        All className attributes must have a matching entry in the styleVariables 
        where the item's key value matches the className attribute's value.
        """)
        let jsxContent: String

        @Guide(description: """
        The widget's positioning, in Standard CSS format. 
        CRITICAL: Use ONLY these positioning patterns:
        - "position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);" (centers widget)
        - "position: absolute; top: 20px; left: 20px;" (positions at top-left with offset)
        DO NOT use: position: relative, display: flex, justify-content, align-items, flex-direction, etc.
        """)
        let cssPositioning: String

        @Guide(description: """
        A JSON dictionary where each key is the exact style variable name (with a 'Style' suffix, e.g., 'outputDivStyle') that you will use as className in your JSX: <div className={outputDivStyle}>.
        - Each key must appear as a variable assignment in the generated JavaScript: const outputDivStyle = css`...`;
        - In your JSX, always use className={outputDivStyle} (not a string).
        - Example: {"outputDivStyle": "padding: 10px; color: red;", "titleStyle": "font-weight: bold;"}
        - Only use camelCase or underscores in names (no hyphens allowed).
        - Every style variable used in JSX must have a corresponding entry in this dictionary.
        - This must be valid JSON format with double quotes around keys and values.
        """)
        let styleVariables: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        do {
            // Validate arguments
            guard !arguments.bashCommand.isEmpty else {
                throw ToolSendWidgetToOutputError.emptyBashCommand
            }
            
            guard arguments.refreshFrequency > 0 else {
                throw ToolSendWidgetToOutputError.invalidRefreshFrequency
            }
            
            guard !arguments.jsxContent.isEmpty else {
                throw ToolSendWidgetToOutputError.emptyJsxContent
            }
            
            guard !arguments.cssPositioning.isEmpty else {
                throw ToolSendWidgetToOutputError.emptyCssPositioning
            }
            
            // Parse the CSS classes JSON string
            let cssClasses: [String: String]
            do {
                let data = arguments.styleVariables.data(using: .utf8) ?? Data()
                cssClasses = try JSONDecoder().decode([String: String].self, from: data)
            } catch {
                print("⚠️ Warning: Could not parse CSS classes JSON: \(error)")
                cssClasses = [:]
            }
            
            // Log the tool call
            print("🔧 ToolSendWidgetToOutput called with arguments:")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 Bash Command: \(arguments.bashCommand)")
            print("⏱️  Refresh Frequency: \(arguments.refreshFrequency)ms")
            print("🎨 CSS Positioning: \(arguments.cssPositioning)")
            print("📄 JSX Content:")
            print("   \(arguments.jsxContent)")
            print("🎯 CSS Classes (\(cssClasses.count) items):")
            for (className, css) in cssClasses {
                print("   • \(className): \(css)")
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            // Generate JSX script using the new function
            print("📝 Generating JSX script...")
            let jsxScript = generateUbersichtJSX(arguments: arguments)
            
            print("📄 Generated JSX script length: \(jsxScript.count) characters")
            print("📄 JSX script preview: \(String(jsxScript.prefix(200)))...")
            
            // Generate JSX script and save it directly
            print("📝 JSX script generated successfully!")
            print("📄 Generated JSX script length: \(jsxScript.count) characters")
            
            // Save the file directly using FilePickerUtility
            print("💾 Calling FilePickerUtility to save JSX file...")
            let savedPath = await FilePickerUtility.saveFile(
                content: jsxScript,
                defaultName: "index",
                fileExtension: "jsx",
                initialDirectory: "\(NSHomeDirectory())/Library/Application Support/Übersicht/widgets"
            )
            
            if let path = savedPath {
                print("✅ File saved successfully to: \(path)")
                return "Widget JSX script generated and saved to: \(path)"
            } else {
                print("❌ File save was cancelled or failed")
                return "Widget JSX script generated but save was cancelled"
            }
            
        } catch let toolError as ToolSendWidgetToOutputError {
            print("❌ ToolSendWidgetToOutput error: \(toolError.localizedDescription)")
            return toolError.localizedDescription
        } catch {
            print("❌ Unexpected error in ToolSendWidgetToOutput: \(error)")
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
    
    // MARK: - JSX Generation with String Interpolation
    
    private func generateUbersichtJSX(arguments: Arguments) -> String {
        print("🔧 Generating Übersicht JSX with string interpolation...")
        
        // Parse CSS classes from JSON string
        let cssClasses: [String: String]
        do {
            let data = arguments.styleVariables.data(using: .utf8) ?? Data()
            cssClasses = try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("⚠️ Warning: Could not parse CSS classes JSON: \(error)")
            cssClasses = [:]
        }
        
        // Convert CSS classes to CSS variables
        let cssVariables = convertCssClassesToVariables(cssClasses)
        
        // Escape the bash command for JavaScript string interpolation
        let escapedBashCommand = escapeBashCommandForJavaScript(arguments.bashCommand)
        
        // Generate JSX using string interpolation
        let jsxContent = """
        import { css } from 'uebersicht'; // Optional, use when Emotion's css functions are needed.
        import { styled } from 'uebersicht'; // Optional, use when Emotion styled functions are needed.

        /* ----- Übersicht exports ---- */

        export const command = "\(escapedBashCommand)"
        export const refreshFrequency = \(arguments.refreshFrequency)

        export const render = ({ data_in }) => (
            \(arguments.jsxContent)
        );

        export const className = `
        \(arguments.cssPositioning)
        `;

        /* ----- local stuff ---- */

        \(cssVariables)
        """
        
        print("✅ Übersicht JSX generated successfully")
        print("📄 Generated JSX length: \(jsxContent.count) characters")
        
        return jsxContent
    }
    
    private func escapeBashCommandForJavaScript(_ command: String) -> String {
        // Escape double quotes for JavaScript string interpolation
        return command.replacingOccurrences(of: "\"", with: "\\\"")
    }
    
    private func convertCssClassesToVariables(_ cssClasses: [String: String]) -> String {
        if cssClasses.isEmpty {
            return "// No CSS classes defined"
        }
        
        return cssClasses.map { className, css in
            "const \(className) = css`\(css)`;"
        }.joined(separator: "\n")
    }
    
    // MARK: - File Operations
    
    // File operations now handled by FilePickerUtility in ChatCore
    
    // MARK: - JSX Generation
    
    // Custom error types for the tool
    enum ToolSendWidgetToOutputError: LocalizedError {
        case emptyBashCommand
        case invalidRefreshFrequency
        case emptyJsxContent
        case emptyCssPositioning
        case unexpectedError(Error)
        case fileSaveCancelled
        case fileWriteError(Error)
        
        var errorDescription: String? {
            switch self {
            case .emptyBashCommand:
                return "Bash command cannot be empty"
            case .invalidRefreshFrequency:
                return "Refresh frequency must be greater than 0"
            case .emptyJsxContent:
                return "JSX content cannot be empty"
            case .emptyCssPositioning:
                return "CSS positioning cannot be empty"
            case .unexpectedError(let error):
                return "Unexpected error: \(error.localizedDescription)"
            case .fileSaveCancelled:
                return "File save operation cancelled by user"
            case .fileWriteError(let error):
                return "Error writing file: \(error.localizedDescription)"
            }
        }
    }
} 

