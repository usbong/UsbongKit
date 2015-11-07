//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Joe Amanse on 07/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

class TreeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressExit(sender: AnyObject) {
        print("Did Press Exit")
        dismissViewControllerAnimated(true, completion: nil)
    }
}
