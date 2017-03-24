//
//  TextFieldTableViewCell.swift
//  UsbongKit
//
//  Created by Joe Amanse on 12/02/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

open class TextFieldTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet open weak var textField: UITextField!
    
    fileprivate static let accessoryViewHeight: CGFloat = 44
    fileprivate lazy var _keyboardAccessoryView: UIView? = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: type(of: self).accessoryViewHeight))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TextFieldTableViewCell.didPressDone(_:)))
        
        toolbar.items = [flexibleSpace, doneBarButton]
        
        return toolbar
    }()
    
    open var keyboardAccessoryView: UIView? {
        get {
            return _keyboardAccessoryView
        }
        set {
            _keyboardAccessoryView = newValue
            textField.inputAccessoryView = _keyboardAccessoryView
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
        let shouldReturn: Bool = textField.delegate?.textFieldShouldEndEditing?(textField) ?? true
        
        if shouldReturn {
            textField.resignFirstResponder()
        }
    }
}
