//
//  CheckboxTableViewCell.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/15/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

open class CheckboxTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet open weak var checkboxButton: CheckboxButton!
    @IBOutlet open weak var titleLabel: UILabel!
    
    open var checkboxButtonSelected: Bool {
        get {
            return checkboxButton.isSelected
        }
        set {
            checkboxButton.isSelected = newValue
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
    
}
