//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/29/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import UsbongKit

class TreeViewController: UIViewController, PlayableTree, HintsTextViewDelegate, AutoPlayableTree {
    
    @IBOutlet weak var previousNextSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nodeView: NodeView!
    var tree: UsbongTree?
    
    var treeURL: URL?
    var treeRootURL: URL?
    
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var voiceOverAudioPlayer: AVAudioPlayer?
    
    lazy var voiceOverCoordinator: VoiceOverCoordinator = VoiceOverCoordinator(delegate: self, playableTree: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = treeURL else { return }
        guard let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(url) else { return }
        
        self.treeRootURL = treeRootURL
        print(treeRootURL)
        
        tree = UsbongTree(treeRootURL: treeRootURL)
        
        navigationItem.title = tree?.title
        
        reloadNode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        stopVoiceOver()
        
        // Print output
        let output: String = tree?.generateOutput(UsbongAnswersGeneratorDefaultCSVString.self) ?? ""
        print("Output: \(output)")
        
        // Save csv on exit
        tree?.saveOutputData(UsbongAnswersGeneratorDefaultCSVString.self) { (success, filePath) in
            print("Answers saved to \(filePath): \(success)")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didPressExit(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressMore(_ sender: AnyObject) {
        showAvailableActions(sender)
    }
    @IBAction func didChangeSegmentedControllerValue(_ sender: AnyObject?) {
        if let segmentedControl = sender as? UISegmentedControl {
            let index = segmentedControl.selectedSegmentIndex
            switch index {
            case 0:
                transitionToPreviousNode()
            case 1:
                transitionToNextNode()
            default:
                break
            }
        }
    }
}
