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

@Observable
class OutputUbersichtWidget: Tool {
    let name = "OutputUbersichtWidget"
    let description = "Sends a Übersicht widget's properties to an output and returns a success confirmation message."
    
    @Generable
    struct Arguments {
        @Guide(description: "A bash command that will be executed later.")
        let bashCommand: String

        @Guide(description: "The widget's refresh frequency in milliseconds.")
        let refreshFrequency: Int
        
        @Guide(description: """
        The widget's JSX content. Each DOM element can contain a className attribute.
        All className attributes must have a matching entry in the classNameDictionary 
        where the item's key value matches the className attribute's value.
        """)
        let jsxContent: String

        @Guide(description: "The widget's positioning, in Standard CSS format ().")
        let cssPositioning: String

        @Guide(description: """
        JSON string representation of Emotion-style CSS items. Format: {"className1": "css1", "className2": "css2"}.
        The key strings match className attributes in the jsxContent. Use "{}" if no CSS classes are needed.
        Note: CSS class names should use camelCase or underscores, not hyphens, as they become JavaScript variable names.
        """)
        let classNameDictionary: String
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
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
                let data = arguments.classNameDictionary.data(using: .utf8) ?? Data()
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
                defaultName: "widget",
                fileExtension: "jsx",
                initialDirectory: "\(NSHomeDirectory())/Library/Application Support/Übersicht/widgets"
            )
            
            if let path = savedPath {
                print("✅ File saved successfully to: \(path)")
                return ToolOutput("Widget JSX script generated and saved to: \(path)")
            } else {
                print("❌ File save was cancelled or failed")
                return ToolOutput("Widget JSX script generated but save was cancelled")
            }
            
        } catch let toolError as ToolSendWidgetToOutputError {
            print("❌ ToolSendWidgetToOutput error: \(toolError.localizedDescription)")
            throw toolError
        } catch {
            print("❌ Unexpected error in ToolSendWidgetToOutput: \(error)")
            throw ToolSendWidgetToOutputError.unexpectedError(error)
        }
    }
    
    // MARK: - JSX Generation with String Interpolation
    
    private func generateUbersichtJSX(arguments: Arguments) -> String {
        print("🔧 Generating Übersicht JSX with string interpolation...")
        
        // Parse CSS classes from JSON string
        let cssClasses: [String: String]
        do {
            let data = arguments.classNameDictionary.data(using: .utf8) ?? Data()
            cssClasses = try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("⚠️ Warning: Could not parse CSS classes JSON: \(error)")
            cssClasses = [:]
        }
        
        // Convert CSS classes to CSS variables
        let cssVariables = convertCssClassesToVariables(cssClasses)
        
        // Generate JSX using string interpolation
        let jsxContent = """
        import { css } from 'uebersicht'; // Optional, use when Emotion's css functions are needed.
        import { styled } from 'uebersicht'; // Optional, use when Emotion styled functions are needed.

        /* ----- Übersicht exports ---- */

        export const command = "\(arguments.bashCommand)"
        export const refreshFrequency = \(arguments.refreshFrequency)

        export const render = ({ data_in }) => (
            \(arguments.jsxContent)
        );

        export const className = css`
        \(arguments.cssPositioning)
        `;

        /* ----- local stuff ---- */

        \(cssVariables)
        """
        
        print("✅ Übersicht JSX generated successfully")
        print("📄 Generated JSX length: \(jsxContent.count) characters")
        
        return jsxContent
    }
    
    private func convertCssClassesToVariables(_ cssClasses: [String: String]) -> String {
        if cssClasses.isEmpty {
            return "// No CSS classes defined"
        }
        
        return cssClasses.map { className, css in
            "const \(className)Style = css`\(css)`;"
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
