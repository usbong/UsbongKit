//
//  DateTableViewCell.swift
//  UsbongKit
//
//  Created by Joe Amanse on 13/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

public class DateTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet public weak var datePicker: UIDatePicker!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
