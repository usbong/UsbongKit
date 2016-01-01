//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/29/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import AVFoundation
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
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var voiceOverAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = treeURL {
            if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(url) {
                self.treeRootURL = treeRootURL
                print(treeRootURL)
                
                tree = UsbongTree(treeRootURL: treeRootURL)
                
                reloadNode()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        stopVoiceOver()
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
                if let tree = self.tree {
                    self.startVoiceOverAudioInTree(tree)
                }
            } else {
                self.stopVoiceOver()
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
    
    func reloadNode() {
        guard let tree = self.tree else {
            return
        }
        
        if let node = tree.currentNode {
            nodeView.node = node
            
            // Background image
            if let backgroundImagePath = tree.backgroundImageURL?.path {
                nodeView.backgroundImage = UIImage(contentsOfFile: backgroundImagePath)
            }
            
            // Background audio - change only if not empty and different
            if let currentURL = backgroundAudioPlayer?.url {
                if let newURL = tree.backgroundAudioURL {
                    if newURL != currentURL {
                        backgroundAudioPlayer?.stop()
                        backgroundAudioPlayer = nil
                        
                        loadBackgroundAudioInTree(tree)
                    }
                }
            } else {
                // If current URL is empty, attempt load
                loadBackgroundAudioInTree(tree)
            }
            
            // Voice-over
            if voiceOverOn {
                startVoiceOverInTree(tree)
            }
        }
    }
    
    // MARK: Background audio
    func loadBackgroundAudioInTree(tree: UsbongTree) {
        guard let url = tree.backgroundAudioURL else {
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.volume = 0.4
            
            backgroundAudioPlayer = audioPlayer
        } catch let error {
            print("Error loading background audio: \(error)")
        }
    }
    
    // MARK: Voice-over
    func startVoiceOverInTree(tree: UsbongTree) {
        // Attempt to play speech from audio file, if failed, resort to text-to-speech
        if !startVoiceOverAudioInTree(tree) {
            // Start text-to-speech instead
            startTextToSpeechInTree(tree)
        }
    }
    func stopVoiceOver() {
        stopVoiceOverAudio()
        stopTextToSpeech()
    }
    
    func startVoiceOverAudioInTree(tree: UsbongTree) -> Bool {
        guard let voiceOverAudioURL = tree.currentVoiceOverAudioURL else {
            return false
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOfURL: voiceOverAudioURL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("Playing voice-over audio...")
            
            voiceOverAudioPlayer = audioPlayer
            return true
        } catch let error {
            print("Error loading voice-over audio: \(error)")
            return false
        }
    }
    
    func stopVoiceOverAudio() {
        guard let audioPlayer = voiceOverAudioPlayer else {
            return
        }
        
        if audioPlayer.playing {
            audioPlayer.stop()
        }
    }
    
    func startTextToSpeechInTree(tree: UsbongTree) {
        guard let text = (tree.currentNode as? ReadableTextTypeNode)?.readableText else {
            print("No readable text")
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.voice = AVSpeechSynthesisVoice(language: "en-EN")
        
        // Speak
        speechSynthesizer.speakUtterance(utterance)
    }
    func stopTextToSpeech() {
        if speechSynthesizer.speaking {
            speechSynthesizer.stopSpeakingAtBoundary(.Immediate)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "presentLanguages":
            if let languagesTableVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? LanguagesTableViewController {
                if let tree = self.tree {
                    languagesTableVC.languages = tree.availableLanguages
                    languagesTableVC.selectedLanguage = tree.currentLanguage
                    languagesTableVC.didSelectLanguageCompletion = { selectedLanguage in
                        tree.currentLanguage = selectedLanguage
                        
                        self.reloadNode()
                    }
                }
            }
        default:
            break
        }
    }
}
