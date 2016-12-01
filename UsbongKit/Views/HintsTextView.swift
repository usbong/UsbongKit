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
public extension HintsTextViewDelegate where Self: UIViewController {
    public func hintsTextView(textView: HintsTextView, didTapString: String, withHint hint: String) {
        let alertController = UIAlertController(title: "Word Hint", message: hint, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
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
        let hintTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(HintsTextView.didTapTextView(_:)))
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
                }
            }
        }
    }
}

extension NSAttributedString {
    public func attributedStringWithHints(hintsDictionary: [String: String], withColor color: UIColor? = nil) -> NSAttributedString {
        let mutableAttributedText = NSMutableAttributedString(attributedString: self)
        let string = self.string as NSString
        
        // Add hint in each word if available
        string.forEachWord { (word, range) in
            guard let hint = hintsDictionary[word.lowercaseString] else {
                return
            }
            
            var attributes = [String: AnyObject]()
            
            // Add hint
            attributes[ContainsHintKey] = hint
            
            // Set color
            if let targetColor = color {
                attributes[NSForegroundColorAttributeName] = targetColor
            }
            
            mutableAttributedText.addAttributes(attributes, range: range)
        }
        
        return mutableAttributedText
    }
}