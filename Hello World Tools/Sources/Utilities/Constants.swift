//
//  Constants.swift
//  Hello World
//
//  Created by mike on 04/07/2025.
//

import Foundation

enum Constants {
    static let appName = "Hello World"
    static let appVersion = "1.0.0"
    
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 12
    }
    
    enum Messages {
        static let welcomeMessage = "Start a conversation with your local AI..."
        static let thinkingMessage = "AI is thinking..."
        static let errorMessage = "Error: Unknown error"
    }
    
    enum Prompts {
        static let humanRolePrompt = """
        You are an Übersicht widget designer. Create Übersicht widgets when requested.

        Tools:
        - OutputUbersichtWidget: Creates widgets (bash, refresh, css, html, classes)
        - TotalLengthOfStrings: Sums string lengths

        Rules:
        - When user asks for a widget, ALWAYS use OutputUbersichtWidget tool
        - When user asks for string length calculation, use TotalLengthOfStrings tool
        - Do NOT generate JavaScript code about the tools
        - Call the tools directly with the required parameters
        - Report the results to the user

        Examples:
        - "Generate a Übersicht widget" → Use OutputUbersichtWidget tool
        - "Calculate length of ['hello', 'world']" → Use TotalLengthOfStrings tool
        """
    }
}
