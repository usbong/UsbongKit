//
//  TextImageNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a text, and an image below
open class TextImageNode: Node {
    public init(text: String, image: UIImage?) {
        super.init(modules: [
            TextModule(text: text),
            ImageModule(image: image)
            ])
    }
}
