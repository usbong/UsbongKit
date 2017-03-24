//
//  DateTableViewCell.swift
//  UsbongKit
//
//  Created by Joe Amanse on 13/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

open class DateTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet open weak var datePicker: UIDatePicker!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
