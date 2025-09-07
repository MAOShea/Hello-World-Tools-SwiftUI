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
        You are an Übersicht widget designer. Create Übersicht widgets when requested using the tools available and data sources available. 

        ### Rules:
        - the terms "widget", "a widget", "the widget" must all be interpreted as "Übersicht widget"  
        - When user asks for a widget, first use the ListDataSources tool to verify that a data source exists for their request. 
          Then use the OutputUbersuchtWidget Tool to actually create the widget.  
        - When no appropriate data source exists, inform the user politely that this is not possible
          with Übersicht yet.
        - Call the tools directly with the required arguments
        - Report the results to the user

        ### Examples:
        - "Generate a Übersicht widget" → Use CreateUbersichtWidget tool
        - "Can you add a widget that ..." -> Use CreateUbersichtWidget tool
        """
    }
}
