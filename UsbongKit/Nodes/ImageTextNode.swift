//
//  TextNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays an image, and text below
open class ImageTextNode: Node {
    public init(image: UIImage?, text: String) {
        super.init(modules: [
            ImageModule(image: image),
            TextModule(text: text)
            ])
    }
}
