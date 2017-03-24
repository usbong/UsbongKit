//
//  ImageModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display an image
open class ImageModule: Module {
    open var image: UIImage? = nil
    
    public init(image: UIImage?) {
        self.image = image
    }
}
