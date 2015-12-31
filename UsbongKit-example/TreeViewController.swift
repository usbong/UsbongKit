//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/29/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
@testable import UsbongKit

class TreeViewController: UIViewController {
    
    @IBOutlet weak var nodeView: NodeView!
    @IBOutlet weak var previousNextSegmentedControl: UISegmentedControl!
    
    var treeURL: NSURL?
    var treeRootURL: NSURL?
    var tree: UsbongTree?
    
    var voiceOverOn: Bool {
        get {
            // Default to true if not yet set
            let standardUserDefaults = NSUserDefaults.standardUserDefaults()
            if standardUserDefaults.objectForKey("SpeechOn") == nil {
                standardUserDefaults.setBool(true, forKey: "SpeechOn")
            }
            return standardUserDefaults.boolForKey("SpeechOn")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "SpeechOn")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = treeURL {
            if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(url) {
                self.treeRootURL = treeRootURL
                print(treeRootURL)
                
                let tree = UsbongTree(treeRootURL: treeRootURL)
                self.tree = tree
                
                if let startingNode = tree.currentNode {
                    nodeView.node = startingNode
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func didPressExit(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressMore(sender: AnyObject) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let onOrOffText = voiceOverOn ? "Off" : "On"
        let speechAction = UIAlertAction(title: "Speech \(onOrOffText)", style: .Default) { (action) -> Void in
            let turnOn = !self.voiceOverOn
            
            // If toggled to on, start voice-over
            if turnOn {
                print("Start voice-over")
//                self.startVoiceOver()
            } else {
                print("Stop voice-over")
//                self.stopVoiceOver()
            }
            
            self.voiceOverOn = turnOn
        }
        let setLanguageAction = UIAlertAction(title: "Set Language", style: .Default) { (action) -> Void in
            self.showChooseLanguageScreen()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionController.addAction(speechAction)
        actionController.addAction(setLanguageAction)
        actionController.addAction(cancelAction)
        
        // For iPad action sheet behavior (similar to a popover)
        if let popover = actionController.popoverPresentationController, let barButtonItem = sender as? UIBarButtonItem {
            popover.barButtonItem = barButtonItem
        }
        
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    // MARK: Functions
    
    func showChooseLanguageScreen() {
        performSegueWithIdentifier("presentLanguages", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "presentLanguages":
            print(tree?.availableLanguages ?? [])
            
            if let languagesTableVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? LanguagesTableViewController {
                if let tree = self.tree {
                    languagesTableVC.languages = tree.availableLanguages
                    languagesTableVC.selectedLanguage = tree.currentLanguage
                    languagesTableVC.didSelectLanguageCompletion = {
                        tree.currentLanguage = languagesTableVC.selectedLanguage
                        if let node = tree.currentNode {
                            self.nodeView.node = node
                        }
                    }
                }
            }
        default:
            break
        }
    }
}
