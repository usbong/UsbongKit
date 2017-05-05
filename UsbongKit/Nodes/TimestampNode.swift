//
//  TextNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a time stamp with text on top
open class TimestampNode: Node {
    internal var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
    
    public init(text: String, date: Date = Date()) {
        let timeString = dateFormatter.string(from: date)
        
        super.init(modules: [
            TextModule(text: text),
            TextModule(text: timeString)
            ])
    }
    
    open var date: Date? {
        get {
            let timeString = (modules[1] as! TextModule).text
            return dateFormatter.date(from: timeString)
        }
        set {
            let timeString: String
            
            if let date = newValue {
                timeString = dateFormatter.string(from: date)
            } else {
                timeString = ""
            }
            
            (modules[1] as! TextModule).text = timeString
        }
    }
}
