//
//  ImageNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays an image
public class ImageNode: Node {
    public init(image: UIImage?) {
        super.init(modules: [ImageModule(image: image)])
    }
}
