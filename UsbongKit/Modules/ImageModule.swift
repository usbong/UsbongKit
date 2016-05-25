//
//  ImageModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display an image
public class ImageModule: Module {
    public var image: UIImage? = nil
    
    public init(image: UIImage?) {
        self.image = image
    }
}
