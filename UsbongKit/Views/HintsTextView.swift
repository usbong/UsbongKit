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
    func hintsTextView(_ textView: HintsTextView, didTapString: String, withHint hint: String)
}
public extension HintsTextViewDelegate where Self: UIViewController {
    public func hintsTextView(_ textView: HintsTextView, didTapString: String, withHint hint: String) {
        let alertController = UIAlertController(title: "Word Hint", message: hint, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

open class HintsTextView: UITextView {
    weak open var hintsTextViewDelegate: HintsTextViewDelegate?
    
    override open func awakeFromNib() {
        customInitialization()
    }
    
    public init() {
        super.init(frame: CGRect.zero, textContainer: NSTextContainer())
        isEditable = false
        customInitialization()
    }
    
    public init(frame: CGRect) {
        super.init(frame: frame, textContainer: NSTextContainer())
        isEditable = false
        customInitialization()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isEditable = false
        customInitialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func customInitialization() {
        loadHintTapRecognizer()
    }
    fileprivate func loadHintTapRecognizer() {
        let hintTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(HintsTextView.didTapTextView(_:)))
        self.addGestureRecognizer(hintTapRecognizer)
    }
    
    final func didTapTextView(_ sender: AnyObject) {
        if let recognizer = sender as? UITapGestureRecognizer {
            var location = recognizer.location(in: self)
            location.x -= textContainerInset.left
            location.y -= textContainerInset.top
            
            let charIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            if charIndex < self.textStorage.length {
                var range: NSRange? = NSRange(location: 0, length: 1)
                if let hint = attributedText.attribute(ContainsHintKey, at: charIndex, effectiveRange: &range!) as? String {
                    let tappedString = (attributedText.string as NSString).substring(with: range ?? NSRange()) as String
                    hintsTextViewDelegate?.hintsTextView(self, didTapString: tappedString, withHint: hint)
                }
            }
        }
    }
}

extension NSAttributedString {
    public func attributedStringWithHints(_ hintsDictionary: [String: String], withColor color: UIColor? = nil) -> NSAttributedString {
        let mutableAttributedText = NSMutableAttributedString(attributedString: self)
        let string = self.string as NSString
        
        // Add hint in each word if available
        string.forEachWord { (word, range) in
            guard let hint = hintsDictionary[word.lowercased] else {
                return
            }
            
            var attributes = [String: AnyObject]()
            
            // Add hint
            attributes[ContainsHintKey] = hint as AnyObject
            
            // Set color
            if let targetColor = color {
                attributes[NSForegroundColorAttributeName] = targetColor
            }
            
            mutableAttributedText.addAttributes(attributes, range: range)
        }
        
        return mutableAttributedText
    }
}
