//
//  TextNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a time stamp with text on top
public class TimestampNode: Node {
    internal var dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.timeStyle = .MediumStyle
        return df
    }()
    
    public init(text: String, date: NSDate = NSDate()) {
        let timeString = dateFormatter.stringFromDate(date)
        
        super.init(modules: [
            TextModule(text: text),
            TextModule(text: timeString)
            ])
    }
    
    public var date: NSDate? {
        get {
            let timeString = (modules[1] as! TextModule).text
            return dateFormatter.dateFromString(timeString)
        }
        set {
            let timeString: String
            
            if let date = newValue {
                timeString = dateFormatter.stringFromDate(date)
            } else {
                timeString = ""
            }
            
            (modules[1] as! TextModule).text = timeString
        }
    }
}
