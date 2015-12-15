//
//  LinkTableViewCell.swift
//  UsbongKit
//
//  Created by Joe Amanse on 27/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import RadioButton

public class LinkTableViewCell: UITableViewCell {

    @IBOutlet public weak var radioButton: RadioButton!
    @IBOutlet public weak var titleLabel: UILabel!
    
    public var radioButtonSelected: Bool {
        get {
            return radioButton.selected
        }
        set {
            radioButton.selected = newValue
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        radioButton.fillCircleColor = UIColor.darkGrayColor()
        radioButton.circleColor = UIColor.blackColor()
        radioButton.circleLineWidth = 1.0
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
