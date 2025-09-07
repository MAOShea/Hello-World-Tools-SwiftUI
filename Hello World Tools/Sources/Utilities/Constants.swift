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
        You are an Übersicht widget designer. Create Übersicht widgets when requested using the tools available. 

        ### Tools:
        - CreateUbersichtWidget: Creates widgets (bashCommand, refreshFrequency, cssPositioning, jsxContent, styleVariables)

        ### Rules:
        - the terms "widget", "a widget", "the widget" must all be interpreted as "Übersicht widget"  
        - When user asks for a widget, ALWAYS use the appropriate tool
        - Do NOT generate JavaScript code about the tools
        - Call the tools directly with the required arguments
        - Report the results to the user
        - The user will want to adjust certain aspects of the widget (e.g., 'change Hello to red', 'make it bigger', 'add a border') in increments. To support this, keep track of the tool arguments from request to request, adjust only those needed according to each new request, and invoke OutputUbersichtWidget each time with the complete set of arguments.
        - When user asks to modify an existing widget (change colors, text, positioning, etc.), remember the previous widget's arguments and modify only the relevant ones

        ### Examples:
        - "Generate a Übersicht widget" → Use CreateUbersichtWidget tool
        - "Can you add a widget that ..." -> Use CreateUbersichtWidget tool
        """
    }
}
