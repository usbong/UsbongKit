//
//  NSString+Words.swift
//  UsbongKit
//
//  Created by Chris Amanse on 11/29/16.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

internal extension NSString {
    internal func forEachWord(block: (NSString, NSRange) throws -> Void) rethrows {
        var foundWord = false
        var firstIndexOfWord: Int = 0
        
        let nonWordCharacterSet = NSMutableCharacterSet.whitespaceAndNewline()
        nonWordCharacterSet.formUnion(with: .punctuationCharacters)
        nonWordCharacterSet.removeCharacters(in: "-")
        
        for i in 0 ..< self.length {
            let char = self.character(at: i)
            
            let isWordCharacter = !nonWordCharacterSet.characterIsMember(char)
            
            // Found first character in word
            if !foundWord && isWordCharacter {
                foundWord = true
                firstIndexOfWord = i
            }
            
            // Found last character of word
            let isEndOfString = i + 1 == self.length
            if (foundWord && !isWordCharacter) || (foundWord && isEndOfString) {
                let endIndexOfWord = isWordCharacter ? i + 1 : i
                
                let range = NSRange(location: firstIndexOfWord, length: endIndexOfWord - firstIndexOfWord)
                let word = self.substring(with: range)
                
                try block(word as NSString, range)
                
                foundWord = false
            }
        }
    }
}
