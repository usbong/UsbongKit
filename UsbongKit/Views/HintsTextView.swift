//
//  HintsTextView.swift
//  test
//
//  Created by Chris Amanse on 10/9/15.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

private let ContainsHintKey = "ContainsHintKey"

public protocol HintsTextViewDelegate: UITextViewDelegate {
    func hintsTextView(textView: HintsTextView, didTapString: String, withHint hint: String)
}

public class HintsTextView: UITextView {
    weak public var hintsTextViewDelegate: HintsTextViewDelegate?
    
    override public func awakeFromNib() {
        customInitialization()
    }
    
    public init() {
        super.init(frame: CGRect.zero, textContainer: NSTextContainer())
        editable = false
        customInitialization()
    }
    
    public init(frame: CGRect) {
        super.init(frame: frame, textContainer: NSTextContainer())
        editable = false
        customInitialization()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        editable = false
        customInitialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func customInitialization() {
        loadHintTapRecognizer()
    }
    private func loadHintTapRecognizer() {
        let hintTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTapTextView:"))
        self.addGestureRecognizer(hintTapRecognizer)
    }
    
    final func didTapTextView(sender: AnyObject) {
        if let recognizer = sender as? UITapGestureRecognizer {
            var location = recognizer.locationInView(self)
            location.x -= textContainerInset.left
            location.y -= textContainerInset.top
            
            let charIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            if charIndex < self.textStorage.length {
                var range: NSRange? = NSRange(location: 0, length: 1)
                if let hint = attributedText.attribute(ContainsHintKey, atIndex: charIndex, effectiveRange: &range!) as? String {
                    let tappedString = (attributedText.string as NSString).substringWithRange(range ?? NSRange()) as String ?? ""
                    hintsTextViewDelegate?.hintsTextView(self, didTapString: tappedString, withHint: hint)
                    print("\(tappedString); \(hint)")
                }
            }
        }
    }
}

extension NSAttributedString {
    public func attributedStringWithHints(hintsDictionary: [String: String]) -> NSAttributedString {
        let mutableAttributedText = NSMutableAttributedString(attributedString: self)
        let string = self.string as NSString
        let stringLength = string.length
        
        for (key, value) in hintsDictionary {
            var range = NSRange(location: 0, length: mutableAttributedText.length)
            let searchString = key
            let searchStringLength = searchString.characters.count
            
            while range.location != NSNotFound {
                range = string.rangeOfString(searchString, options: .CaseInsensitiveSearch, range: range)
                
                if range.location != NSNotFound {
                    // Allow words or phrases only - check for previous and next characters
                    var foundStringIsWord = true
                    
                    // Previous character should be whitespace or newline
                    let whitespaceAndNewLineCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                    if range.location > 0 {
                        let previousCharacterString = string.substringWithRange(NSRange(location: range.location - 1, length: 1))
                        if previousCharacterString.rangeOfCharacterFromSet(whitespaceAndNewLineCharacterSet) == nil {
                            foundStringIsWord = false
                        }
                    }
                    
                    // Next character should be whitespace, newline or punctuation
                    let nextCharacterLocation = range.location + range.length
                    if foundStringIsWord && nextCharacterLocation < string.length {
                        let validCharacterSet = NSMutableCharacterSet.punctuationCharacterSet()
                        validCharacterSet.formUnionWithCharacterSet(whitespaceAndNewLineCharacterSet)
                        
                        let nextCharacterString = string.substringWithRange(NSRange(location: nextCharacterLocation, length: 1))
                        if nextCharacterString.rangeOfCharacterFromSet(validCharacterSet) == nil {
                            foundStringIsWord = false
                        }
                    }
                    
                    if foundStringIsWord && mutableAttributedText.attribute(ContainsHintKey, atIndex: range.location, longestEffectiveRange: nil, inRange: range) == nil {
                        let targetRange = NSRange(location: range.location, length: searchStringLength)
                        mutableAttributedText.addAttributes([ContainsHintKey: value], range: targetRange)
                        
                    }
                    
                    let newLocation = range.location + range.length
                    range = NSRange(location: newLocation, length: stringLength - newLocation)
                }
            }
        }
        
        return mutableAttributedText
    }
}