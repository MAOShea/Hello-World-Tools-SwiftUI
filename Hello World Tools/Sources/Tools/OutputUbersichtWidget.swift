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
    let name = "CreateUbersichtWidget"
    let description = "Creates an Übersicht Widget. Call this tool when prompted to create a widget."
    
    
    private let directory = "\(NSHomeDirectory())/Library/Application Support/Übersicht/widgets"
    
    @Generable
    struct Arguments: Codable {
        @Guide(description: """
        A bash command who's output will be passed to the JSX body as {output}
        """)
        let bashCommand: String

        @Guide(description: "The widget's refresh frequency in milliseconds.")
        let refreshFrequency: Int
        
        @Guide(description: """
        A React functional component as a JavaScript arrow function that renders the widget body. 
        It receives a single "output" prop. Example: ({output}) => { return <h1>output</h1> }
        """)
        let renderFunction: String

        @Guide(description: """
        The widget's absolute positioning in Standard CSS format. Example: top: 20px; left: 20px; Only absolute positioning works.
        """)
        let cssPositioning: String
    }
    

    
    func call(arguments: Arguments) async throws -> String {
        
        let errors = validateRenderFunction(code: arguments.renderFunction)
        if let errorMessage = errors {
            let fullMessage = "Error creating widget. \(arguments.renderFunction) is an invalid render function: \(errorMessage)"
            print("DEBUG: \(fullMessage)")
            
            return fullMessage;
        }
        
        
        
        let jsxScript = generateUbersichtJSX(arguments: arguments)
        
        
        do {
            let filePath = "\(directory)/index.jsx"
            try jsxScript.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
            return "Widget JSX script generated and saved to: \(filePath)"
        } catch {
            return "Widget JSX script generated but failed to save: \(error.localizedDescription)"
        }
            
        
    }
    
    private func validateRenderFunction(code: String) -> String? {
        return lintJSX(source: "import React from 'react'; \(code)")
    }
    
    
    // MARK: - JSX Generation with String Interpolation
    
    private func generateUbersichtJSX(arguments: Arguments) -> String {
        print("🔧 Generating Übersicht JSX with string interpolation...")
        
        // Escape the bash command for JavaScript string interpolation
        let escapedBashCommand = escapeBashCommandForJavaScript(arguments.bashCommand)
        
        // Generate JSX using string interpolation
        let jsxContent = """
        import { css, React } from 'uebersicht'; 
        import { styled } from 'uebersicht'; // Optional, use when Emotion styled functions are needed.

        /* ----- Übersicht exports ---- */

        export const command = "\(escapedBashCommand)"
        export const refreshFrequency = \(arguments.refreshFrequency)

        export const render = \(arguments.renderFunction)

        export const className = "\(arguments.cssPositioning)";
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


