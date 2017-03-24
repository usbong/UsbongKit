//
//  RadioTableViewCell.swift
//  UsbongKit
//
//  Created by Joe Amanse on 27/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

open class RadioTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet open weak var radioButton: RadioButton!
    @IBOutlet open weak var titleLabel: UILabel!
    
    open var radioButtonSelected: Bool {
        get {
            return radioButton.isSelected
        }
        set {
            radioButton.isSelected = newValue
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        radioButton.fillCircleColor = UIColor.darkGray
        radioButton.circleColor = UIColor.black
        radioButton.circleLineWidth = 1.0
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open override func prepareForReuse() {
//        let oldValue = radioButton.selected
        radioButton.isSelected = false
        
        super.prepareForReuse()
    }
}
