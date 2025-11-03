//
//  ToolsEnabledAIService.swift
//  Hello World Tools
//
//  Created by mike on 15/07/2025.
//

import Foundation
import FoundationModels
import ChatCore
import SwiftUI
import Combine
import Playgrounds

public final class ToolsEnabledAIService: AIServiceProtocol, @unchecked Sendable {
    @Published public var isLoading = false
    @Published public var lastError: String?
    
    private let session: LanguageModelSession
    
    public init() {
        session = LanguageModelSession(
            tools: [WriteUbersichtWidgetToFileSystem(), ListDataSourcesTool()],
            instructions: Constants.Prompts.humanRolePrompt2
        )
        session.prewarm()
    }
    
    @MainActor
    public func sendMessage(_ input: String) async -> String? {
        isLoading = true
        lastError = nil
        
        do {
            let response = try await session.respond(to: input)
            
            // Log response structure to understand tool call JSON format
            print("🔍 DEBUG: Response received")
            print("🔍 DEBUG: Response type: \(type(of: response))")
            print("🔍 DEBUG: Response description: \(response)")
            print("🔍 DEBUG: Response content: \(response.content)")
            
            // Try to inspect response using reflection to see all properties
            let mirror = Mirror(reflecting: response)
            print("🔍 DEBUG: Response properties:")
            for child in mirror.children {
                print("🔍 DEBUG:   \(child.label ?? "unknown"): \(child.value)")
            }
            
            // Extract and log tool calls from transcriptEntries
            print("🔍 DEBUG: Extracting tool calls from transcriptEntries:")
            let transcriptMirror = Mirror(reflecting: response.transcriptEntries)
            
            // Convert transcriptEntries to an array to iterate
            let transcriptArray = Array(response.transcriptEntries)
            for (index, entry) in transcriptArray.enumerated() {
                let entryString = String(describing: entry)
                
                // Look for tool call entries
                if entryString.contains("ToolCalls") {
                    print("🔍 DEBUG: Tool Call Entry #\(index):")
                    print("🔍 DEBUG:   Raw: \(entryString)")
                    
                    // Try to extract tool name and JSON arguments
                    if let toolCallRange = entryString.range(of: "ToolCalls) ") {
                        let afterPrefix = String(entryString[toolCallRange.upperBound...])
                        if let colonRange = afterPrefix.range(of: ": ") {
                            let toolName = String(afterPrefix[..<colonRange.lowerBound])
                            let jsonPart = String(afterPrefix[colonRange.upperBound...])
                            print("🔍 DEBUG:   Tool Name: \(toolName)")
                            print("🔍 DEBUG:   JSON Arguments: \(jsonPart)")
                        }
                    }
                }
                
                // Also log tool outputs for context
                if entryString.contains("ToolOutput") {
                    print("🔍 DEBUG: Tool Output Entry #\(index):")
                    print("🔍 DEBUG:   Raw: \(entryString)")
                }
            }
            
            isLoading = false
            return response.content
        } catch {
            isLoading = false
            
            // Handle specific model availability error
            if let generationError = error as? LanguageModelSession.GenerationError {
                switch generationError {
                case .assetsUnavailable:
                    lastError = "AI model is not available. Please download the model in System Settings > AI."
                default:
                    lastError = "AI Error: \(generationError.localizedDescription)"
                }
            } else {
                lastError = "Failed to send message: \(error.localizedDescription)"
            }
            
            print("❌ AI Error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error description: \(error.localizedDescription)")
            
            // Log more details for debugging content safety issues
            if error.localizedDescription.contains("unsafe") || error.localizedDescription.contains("content") {
                print("🔍 DEBUG: Potential content safety issue detected")
                print("🔍 DEBUG: Input that triggered error: \(input)")
                print("🔍 DEBUG: Full error details: \(error)")
            }
            
            // Log error structure to find raw JSON format
            let errorMirror = Mirror(reflecting: error)
            print("🔍 DEBUG: Error properties:")
            for child in errorMirror.children {
                print("🔍 DEBUG:   \(child.label ?? "unknown"): \(child.value)")
            }
            
            // Try to extract raw text from decoding errors
            if let generationError = error as? LanguageModelSession.GenerationError {
                let errorMirror = Mirror(reflecting: generationError)
                print("🔍 DEBUG: GenerationError properties:")
                for child in errorMirror.children {
                    print("🔍 DEBUG:   \(child.label ?? "unknown"): \(child.value)")
                }
            }
            
            return nil
        }
    }
}

#Playground {
    let session = LanguageModelSession(
        tools: [WriteUbersichtWidgetToFileSystem()],
        instructions: Constants.Prompts.humanRolePrompt2
    )

    let response = try await session.respond(
        to: "create a widget that shows me my free disk space"
    )
    print(response)
}
