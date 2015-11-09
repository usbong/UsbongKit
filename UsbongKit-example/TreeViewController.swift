//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Joe Amanse on 07/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import UsbongKit

private enum TransitionDirection {
    case Backward, Forward
}

class TreeViewController: UIViewController {

    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var taskNodeView: TaskNodeView!
    
    var taskNodeGenerator: UsbongTaskNodeGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let treeURL = NSBundle.mainBundle().URLForResource("Usbong iOS", withExtension: "utree") {
            if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(treeURL) {
                taskNodeGenerator = UsbongTaskNodeGeneratorXML(treeRootURL: treeRootURL)
                
                navigationItem.title = taskNodeGenerator?.title ?? "Unknown"
            }
        }
        taskNodeView.taskNode = TextDisplayTaskNode(text: "Hello, World!\nHello!")
        
        if let firstTaskNode = taskNodeGenerator?.currentTaskNode {
            taskNodeView.taskNode = firstTaskNode
            
            // Load background audio at start
//            loadBackgroundAudio()
            
            // Start voice-over if on
//            if voiceOverOn {
//                startVoiceOver()
//            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func didPressExit(sender: AnyObject) {
        print("Did Press Exit")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressMore(sender: AnyObject) {
        print("Did Press More")
    }
    
    @IBAction func didPressPrevious(sender: AnyObject) {
        print("Did Press Previous")
        
        transitionWithDirection(.Backward)
    }
    
    @IBAction func didPressNext(sender: AnyObject) {
        print("Did Press Next")
        
        transitionWithDirection(.Forward)
    }
    
    // MARK: - Custom
    
    private func reloadCurrentTaskNode() {
        if let currentTaskNode = taskNodeGenerator?.currentTaskNode {
            taskNodeView.taskNode = currentTaskNode
        }
    }
    
    private func transitionWithDirection(direction: TransitionDirection) {
        // Before transition
        if direction == .Backward {
            // Previous
            if taskNodeGenerator?.previousTaskNode == nil {
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                taskNodeGenerator?.transitionToPreviousTaskNode()
            }
            
        } else {
            // Next transition
            if taskNodeGenerator?.currentTaskNode is EndStateTaskNode {
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                taskNodeGenerator?.transitionToNextTaskNode()
            }
        }
        
        reloadCurrentTaskNode()
        
        // Finished transition
        // Change back button title to exit if there are no previous task nodes
        if taskNodeGenerator?.previousTaskNode == nil {
            previousButton.setTitle("Exit", forState: .Normal)
        } else {
            previousButton.setTitle("Back", forState: .Normal)
        }
        
        // Change next button title to exit if transitioned node is end state
        if taskNodeGenerator?.currentTaskNode is EndStateTaskNode {
            nextButton.setTitle("Exit", forState: .Normal)
        } else {
            nextButton.setTitle("Next", forState: .Normal)
        }
    }
}
