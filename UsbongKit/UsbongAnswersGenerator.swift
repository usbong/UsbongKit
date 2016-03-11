//
//  UsbongAnswersGenerator.swift
//  UsbongKit
//
//  Created by Joe Amanse on 12/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public protocol UsbongAnswersGenerator {
    typealias OutputType
    init(states: [UsbongNodeState])
    
    @warn_unused_result
    func generateOutput() -> OutputType
}

public class UsbongAnswersGeneratorDefaultCSVString: UsbongAnswersGenerator {
    public typealias OutputType = String
    
    let states: [UsbongNodeState]
    
    public required init(states: [UsbongNodeState]) {
        self.states = states
    }
    
    public func generateOutput() -> String {
        var finalString = ""
        
        for state in states {
            let transitionName = state.transitionName
            var currentEntry = "";
            
            // Get first character of transition name or index
            let firstCharacter: String
            if let taskNodeType = state.taskNodeType {
                switch taskNodeType {
                case .RadioButtons, .Link:
                    // Use selected index for first character
                    let selectedIndex = (state.fields["selectedIndices"] as? [Int])?.first ?? 0
                    
                    firstCharacter = String(selectedIndex)
                default:
                    // By default, use first character of transition name
                    firstCharacter = String(transitionName.characters.first ?? Character(""))
                }
            } else {
                // By default, use first character of transition name
                firstCharacter = String(transitionName.characters.first ?? Character(""))
            }
            
            // Add first character to current entry
            currentEntry += firstCharacter
            
            // Get additional fields for current entry
            if let taskNodeType = state.taskNodeType {
                switch taskNodeType {
                case .TextField, .TextFieldNumerical, .TextFieldWithUnit, .TextFieldWithAnswer,
                .TextArea, .TextAreaWithAnswer:
                    // Get text input field
                    let textInput = (state.fields["textInput"] as? String) ?? ""
                    
                    currentEntry += "," + textInput
                default:
                    break
                }
            }
            
            // Add entry in final string
            finalString += currentEntry + ";"
        }
        
        return finalString
    }
}

public extension UsbongTree {
    
    func generateOutput<T: UsbongAnswersGenerator>(generatorType: T.Type) -> T.OutputType {
        return generatorType.init(states: usbongNodeStates).generateOutput()
    }
}
