//
//  CheckboxTableViewCell.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/15/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

public class CheckboxTableViewCell: UITableViewCell {
    @IBOutlet public weak var checkboxButton: CheckboxButton!
    @IBOutlet public weak var titleLabel: UILabel!
    
    public var checkboxButtonSelected: Bool {
        get {
            return checkboxButton.selected
        }
        set {
            checkboxButton.selected = newValue
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
    
}
