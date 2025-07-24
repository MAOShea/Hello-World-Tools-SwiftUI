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

public final class ToolsEnabledAIService: AIServiceProtocol, @unchecked Sendable {
    @Published public var isLoading = false
    @Published public var lastError: String?
    
    private let session: LanguageModelSession
    
    public init() {
        print("🔧 DEBUG: Creating tools-enabled session with instructions builder...")
        let instructions = Instructions {
            Constants.Prompts.humanRolePrompt
        }
        print("🔧 DEBUG: Instructions created: \(instructions)")
        
        // Create tools array
        let tools: [any Tool] = [
            OutputUbersichtWidget()
            , TotalLengthOfStrings()
        ]
        
        // Configure session with tools
        session = LanguageModelSession(tools: tools) {
            instructions
        }
        print("✅ Tools-enabled LanguageModelSession created successfully")
        print("🔧 Available tools: \(tools.map { $0.name }.joined(separator: ", "))")
        
        // Prewarm the session like Apple's sample
        session.prewarm()
        print("🔥 Session prewarmed")
    }
    
    @MainActor
    public func sendMessage(_ input: String) async -> String? {
        isLoading = true
        lastError = nil
        
        do {
            print("🤖 Sending message to AI: \(input)")
            let response = try await session.respond(to: input)
            isLoading = false
            print("✅ AI response received: \(response.content)")
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
            
            return nil
        }
    }
}
