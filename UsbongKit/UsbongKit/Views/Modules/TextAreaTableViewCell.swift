//
//  TextAreaTableViewCell.swift
//  UsbongKit
//
//  Created by Joe Amanse on 12/02/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

open class TextAreaTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.inputAccessoryView = keyboardAccessoryView
        }
    }
    
    fileprivate static let accessoryViewHeight: CGFloat = 44
    fileprivate lazy var _keyboardAccessoryView: UIView? = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: type(of: self).accessoryViewHeight))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TextAreaTableViewCell.didPressDone(_:)))
        
        toolbar.items = [flexibleSpace, doneBarButton]
        
        return toolbar
    }()
    
    open var keyboardAccessoryView: UIView? {
        get {
            return _keyboardAccessoryView
        }
        set {
            _keyboardAccessoryView = newValue
            textView.inputAccessoryView = _keyboardAccessoryView
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open func didPressDone(_ sender: AnyObject?) {
        // Ask delegate if should return
        let shouldReturn: Bool = textView.delegate?.textViewShouldEndEditing?(textView) ?? true
        
        if shouldReturn {
            textView.resignFirstResponder()
        }
    }
    
}
