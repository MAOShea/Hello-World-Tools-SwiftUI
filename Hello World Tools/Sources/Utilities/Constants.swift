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
        - When user asks for a widget, ALWAYS use OutputUbersichtWidget tool
        - When user asks for string length calculation, use TotalLengthOfStrings tool
        - Do NOT generate JavaScript code about the tools
        - Call the tools directly with the required arguments
        - Report the results to the user
        - Follow the user's requests exactly as specified. Do not substitute, approximate, or make assumptions about what the user wants. If the user asks for specific colors, use those exact colors. If the user asks for specific positioning, use that exact positioning.
        - The user will want to adjust certain aspects of the widget (e.g., 'change Hello to red', 'make it bigger', 'add a border') in increments. To support this, keep track of the tool arguments from request to request, adjust only those needed according to each new request, and invoke OutputUbersichtWidget each time with the complete set of arguments.
        - When user asks to modify an existing widget (change colors, text, positioning, etc.), remember the previous widget's arguments and modify only the relevant ones
        - Always provide COMPLETE widget arguments (bashCommand, refreshFrequency, cssPositioning, jsxContent, styleVariables) in the new widget
        - Keep unchanged arguments the same as the previous widget, only modify the arguments that need to change

        ### Examples:
        - "Generate a Übersicht widget" → Use CreateUbersichtWidget tool
        - "Can you add a widget that ..." -> Use CreateUbersichtWidget tool
        """
    }
}
