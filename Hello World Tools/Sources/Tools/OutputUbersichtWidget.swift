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
        The widget's HTML content. Each DOM element can contain a className attribute.
        All className attributes must have a matching entry in the classNameDictionary 
        where the item's key value matches the className attribute's value.
        """)
        let htmlContent: String

        @Guide(description: "The widget's positioning, in Standard CSS format ().")
        let cssPositioning: String

        @Guide(description: """
        JSON string representation of Emotion-style CSS items. Format: {"className1": "css1", "className2": "css2"}.
        The key strings match className attributes in the htmlContent. Use "{}" if no CSS classes are needed.
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
            
            guard !arguments.htmlContent.isEmpty else {
                throw ToolSendWidgetToOutputError.emptyHtmlContent
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
            print("📄 HTML Content:")
            print("   \(arguments.htmlContent)")
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
            
            // Write JSX script to disk
            print("💾 Writing JSX script to disk...")
            let filePath = try await writeJSXToDisk(jsxScript: jsxScript)
            
            print("✅ JSX script written successfully!")
            print("📁 File location: \(filePath)")
            
            return ToolOutput("Widget JSX script generated and saved to Übersicht widgets folder")
            
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
            \(arguments.htmlContent)
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
    
    private func writeJSXToDisk(jsxScript: String) async throws -> String {
        print("💾 Starting file write operation...")
        
        // Try to write directly to Übersicht widgets folder first
        let übersichtWidgetsPath = "\(NSHomeDirectory())/Library/Application Support/Übersicht/widgets"
        let directURL = URL(fileURLWithPath: übersichtWidgetsPath).appendingPathComponent("index.jsx")
        
        do {
            // Ensure the directory exists
            try FileManager.default.createDirectory(atPath: übersichtWidgetsPath, withIntermediateDirectories: true)
            
            // Write the file
            try jsxScript.write(to: directURL, atomically: true, encoding: .utf8)
            print("✅ Successfully wrote JSX to Übersicht widgets folder")
            return directURL.path
        } catch {
            print("⚠️ Direct write to Übersicht folder failed: \(error)")
            print("🔄 Falling back to file picker...")
            
            // Fallback to file picker
            return try await showFilePicker(jsxScript: jsxScript)
        }
    }
    
    private func showFilePicker(jsxScript: String) async throws -> String {
        print("📂 Showing file picker dialog...")
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let savePanel = NSSavePanel()
                savePanel.title = "Save Widget JSX File"
                savePanel.nameFieldStringValue = "index.jsx"
                savePanel.allowedContentTypes = [UTType(filenameExtension: "jsx")!]
                savePanel.canCreateDirectories = true
                savePanel.isExtensionHidden = false
                
                // Set the initial directory to Übersicht widgets folder
                let übersichtWidgetsPath = "\(NSHomeDirectory())/Library/Application Support/Übersicht/widgets"
                savePanel.directoryURL = URL(fileURLWithPath: übersichtWidgetsPath)
                
                savePanel.begin { response in
                    if response == .OK {
                        guard let saveURL = savePanel.url else {
                            continuation.resume(throwing: ToolSendWidgetToOutputError.fileSaveCancelled)
                            return
                        }
                        
                        do {
                            try jsxScript.write(to: saveURL, atomically: true, encoding: .utf8)
                            print("✅ File saved successfully via file picker")
                            print("📁 File location: \(saveURL.path)")
                            continuation.resume(returning: saveURL.path)
                        } catch {
                            print("❌ File picker save failed: \(error)")
                            continuation.resume(throwing: ToolSendWidgetToOutputError.fileWriteError(error))
                        }
                    } else {
                        print("❌ File save cancelled by user")
                        continuation.resume(throwing: ToolSendWidgetToOutputError.fileSaveCancelled)
                    }
                }
            }
        }
    }
    
    // MARK: - JSX Generation
    
    // Custom error types for the tool
    enum ToolSendWidgetToOutputError: LocalizedError {
        case emptyBashCommand
        case invalidRefreshFrequency
        case emptyHtmlContent
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
            case .emptyHtmlContent:
                return "HTML content cannot be empty"
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
