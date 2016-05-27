//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 27/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class TreeViewController: UIViewController, PlayableTree, HintsTextViewDelegate, AutoPlayableTree {
    
    @IBOutlet weak var buttonsContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nodeView: NodeView!
    
    lazy var voiceOverCoordinator: VoiceOverCoordinator = VoiceOverCoordinator(delegate: self, playableTree: self)
    
    var tree: UsbongTree?
    
    var treeURL: NSURL?
    var treeRootURL: NSURL?
    
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var voiceOverAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeView.node = TextNode(text: "Loading Tree...")
        nodeView.hintsColor = UIColor.darkGrayColor()
        
        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
            guard let treeURL = self.treeURL else {
                print("No ")
                return
            }
            
            // Create local tree variable for this thread
            let tree: UsbongTree?
            
            // Unpack tree
            if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(treeURL) {
                tree = UsbongTree(treeRootURL: treeRootURL)
            } else {
                tree = nil
            }
            
            // Save tree to self in main thread
            dispatch_async(dispatch_get_main_queue()) {
                self.tree = tree
                
                self.reloadNode()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        let oldInsets = nodeView.tableView.contentInset
        nodeView.tableView.contentInset = UIEdgeInsets(top: oldInsets.top, left: oldInsets.left, bottom: buttonsContainerViewHeightConstraint.constant, right: oldInsets.right)
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
        
        showAvailableActions(sender)
    }
    
    @IBAction func didPressPrevious(sender: AnyObject) {
        print("Did Press Previous")
        
        transitionToPreviousNode()
    }
    
    @IBAction func didPressNext(sender: AnyObject) {
        print("Did Press Next")
        
        transitionToNextNode()
    }
}
