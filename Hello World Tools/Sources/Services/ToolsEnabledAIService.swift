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
            tools: [OutputUbersichtWidget()],
            instructions: Constants.Prompts.humanRolePrompt
        )
        session.prewarm()
    }
    
    @MainActor
    public func sendMessage(_ input: String) async -> String? {
        isLoading = true
        lastError = nil
        
        do {
            let response = try await session.respond(to: input)
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
            
            return nil
        }
    }
}

#Playground {
    let session = LanguageModelSession(
        tools: [OutputUbersichtWidget()],
        instructions: Constants.Prompts.humanRolePrompt
    )

    let response = try await session.respond(
        to: "create a widget that shows the current time in white"
    )
    print(response)
}
