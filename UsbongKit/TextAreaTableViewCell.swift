//
//  TextAreaTableViewCell.swift
//  UsbongKit
//
//  Created by Joe Amanse on 12/02/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

public class TextAreaTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.inputAccessoryView = keyboardAccessoryView
        }
    }
    
    private static let accessoryViewHeight: CGFloat = 44
    private lazy var _keyboardAccessoryView: UIView? = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: self.dynamicType.accessoryViewHeight))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(TextAreaTableViewCell.didPressDone(_:)))
        
        toolbar.items = [flexibleSpace, doneBarButton]
        
        return toolbar
    }()
    
    public var keyboardAccessoryView: UIView? {
        get {
            return _keyboardAccessoryView
        }
        set {
            _keyboardAccessoryView = newValue
            textView.inputAccessoryView = _keyboardAccessoryView
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func didPressDone(sender: AnyObject?) {
        // Ask delegate if should return
        let shouldReturn: Bool = textView.delegate?.textViewShouldEndEditing?(textView) ?? true
        
        if shouldReturn {
            textView.resignFirstResponder()
        }
    }
    
}
