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
class TotalLengthOfStrings: Tool {
    let name = "TotalLengthOfStrings"
    let description = "Calculates the sum of all the lengths of all the strings in the input array and returns the total."
    
    @Generable
    struct Arguments {
        @Guide(description: "An array of strings to calculate the total length of.")
        let strings: [String]
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // Calculate the sum of all string lengths
        let totalLength = arguments.strings.reduce(0) { $0 + $1.count }
        
        print("🔧            called with \(arguments.strings.count) strings, total length: \(totalLength)")
        
        return ToolOutput("Total length of all strings: \(totalLength)")
    }
} 
