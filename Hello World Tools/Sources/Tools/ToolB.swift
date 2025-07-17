//
//  ToolB.swift
//  Hello World Tools
//
//  Created by mike on 15/07/2025.
//
//

import Foundation
import FoundationModels
import SwiftUI

@Observable
class ToolB: Tool {
    let name = "ToolB"
    let description = "Another tool for demonstration with different functionality"
    
    @Generable
    struct Arguments {
        @Guide(description: "The data string to process.")
        let data: String
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // Basic implementation - can be customized based on your needs
        print("🔧 ToolB called with data: \(arguments.data)")
        
        // Example response with different structure
        return ToolOutput("ToolB completed processing data: \(arguments.data)")
    }
} 