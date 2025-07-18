//
//  ToolA.swift
//  Hello World Tools
//
//  Created by mike on 15/07/2025.
//

import Foundation
import FoundationModels
import SwiftUI

@Observable
class ToolSendWidgetToOutput: Tool {
    let name = "Send Übersicht Widget To Output"
    let description = "Sends a Übersicht widget's properties to an output."
    
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
            
            // Simulate widget output processing
            // In a real implementation, this would write to files or send to Übersicht
            print("📤 Sending widget to output...")
            
            return ToolOutput("Widget sent to output successfully with \(cssClasses.count) CSS classes")
            
        } catch let toolError as ToolSendWidgetToOutputError {
            print("❌ ToolSendWidgetToOutput error: \(toolError.localizedDescription)")
            throw toolError
        } catch {
            print("❌ Unexpected error in ToolSendWidgetToOutput: \(error)")
            throw ToolSendWidgetToOutputError.unexpectedError(error)
        }
    }
    
    // Custom error types for the tool
    enum ToolSendWidgetToOutputError: LocalizedError {
        case emptyBashCommand
        case invalidRefreshFrequency
        case emptyHtmlContent
        case emptyCssPositioning
        case unexpectedError(Error)
        
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
            }
        }
    }
} 
