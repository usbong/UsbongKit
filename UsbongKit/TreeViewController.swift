//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 27/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class TreeViewController: UIViewController, HintsTextViewDelegate {
    
    @IBOutlet weak var buttonsContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nodeView: NodeView!
    
    var store: IAPHelper = IAPHelper(bundles: [])
    
    var lastSpeechUtterance: AVSpeechUtterance?
    
    var tree: UsbongTree?
    
    var treeURL: NSURL?
    var treeRootURL: NSURL?
    
    var speechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var voiceOverAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeView.node = TextNode(text: "Loading Tree...")
        nodeView.hintsColor = UIColor.darkGrayColor()
        
        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
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
    
    deinit {
        stopVoiceOver()
    }
    
    // MARK: - Actions
    
    @IBAction func didPressExit(sender: AnyObject) {
        print("Did Press Exit")
        dismissViewControllerAnimated(true, completion: nil)
        stopVoiceOver()
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

// MARK: - Transitions and Presenting Views
extension TreeViewController {
    // MARK: Transitioning nodes
    func transitionToPreviousNode() {
        guard let tree = self.tree else {
            return
        }
        
        if !tree.previousNodeIsAvailable {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        tree.transitionToPreviousNode()
        reloadNode()
    }
    
    func transitionToNextNode() {
        guard let tree = self.tree else {
            return
        }
        
        // Do not transition if tree prevents it
        if tree.shouldPreventTransitionToNextTaskNode {
            // Present no selection alert
            let alertController = UIAlertController(title: "No Selection", message: "Please select one of the choices", preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okayAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        // Dismiss if next node is end state and if PlayableTree says it should dismiss when next node is end state
        if tree.nextNodeIsEndState && shouldDismissWhenNextNodeIsEndState {
            // Save state of last node
            tree.saveStateOfLastNode()
            
            dismissViewControllerAnimated(true, completion: nil)
            stopVoiceOver()
            return
        }
        
        // Dismiss if next node is not available
        if !tree.nextNodeIsAvailable {
            // Save state of last node
            tree.saveStateOfLastNode()
            
            dismissViewControllerAnimated(true, completion: nil)
            stopVoiceOver()
            return
        }
        
        tree.transitionToNextNode()
        reloadNode()
    }
    
    func showAvailableActions(sender: AnyObject?) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Speak
        let speakText = "Speak"
        let speakAction = UIAlertAction(title: speakText, style: .Default) { _ in
            self.stopVoiceOver()
            self.startVoiceOver()
        }
        actionController.addAction(speakAction)
        
        // Voice-over
        let autoSpeakText = "Turn Auto-Speak " + (voiceOverOn ? "Off" : "On")
        let autoSpeakAction = UIAlertAction(title: autoSpeakText, style: .Default) { (action) -> Void in
            self.voiceOverOn = !self.voiceOverOn
        }
        actionController.addAction(autoSpeakAction)
        
        // Auto-play
        let autoPlayText = "Auto-play " + (autoPlay ? "Off" : "On")
        
        let autoPlayAction = UIAlertAction(title: autoPlayText, style: .Default, handler: { action in
            self.autoPlay = !self.autoPlay
        })
        
        actionController.addAction(autoPlayAction)
        
        // Set Language
        let setLanguageAction = UIAlertAction(title: "Set Language", style: .Default) { (action) -> Void in
            self.showChooseLanguageScreen()
        }
        actionController.addAction(setLanguageAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionController.addAction(cancelAction)
        
        // For iPad action sheet behavior (similar to a popover)
        if let popover = actionController.popoverPresentationController {
            if let barButtonItem = sender as? UIBarButtonItem {
                popover.barButtonItem = barButtonItem
            } else if let view = sender as? UIView {
                popover.sourceView = view
            }
        }
        
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    func showChooseLanguageScreen() {
        guard tree != nil else { return }
        
        performSegueWithIdentifier("showLanguages", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "showLanguages":
            guard let tree = self.tree else {
                break
            }
            
            let destinationViewController = (segue.destinationViewController as! UINavigationController).topViewController as! LanguagesTableViewController
            
            destinationViewController.store = store
            destinationViewController.languages = tree.availableLanguages
            destinationViewController.selectedLanguage = tree.currentLanguage
            destinationViewController.didSelectLanguageCompletion = { selectedLanguage in
                tree.currentLanguage = selectedLanguage
                
                // Reload the node
                self.reloadNode()
            }
        default:
            break
        }
    }
}

// MARK: - Node Management and Audio

extension TreeViewController {
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
            
            // If toggled to on, start voice-over, else, stop
            if newValue {
                self.startVoiceOver()
            } else {
                self.stopVoiceOver()
            }
        }
    }
    
    func reloadNode() {
        guard let tree = self.tree else {
            return
        }
        guard let node = tree.currentNode else {
            return
        }
        
        stopVoiceOver()
        
        nodeView.node = node
        nodeView.hintsDictionary = tree.hintsDictionary
        nodeView.hintsTextViewDelegate = self
        
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
                    
                    loadBackgroundAudio()
                }
            }
        } else {
            // If current URL is empty, attempt load
            loadBackgroundAudio()
        }
        
        // Voice-over
        if voiceOverOn {
            startVoiceOver()
        }
    }
    
    // MARK: Background audio
    func loadBackgroundAudio() {
        guard let url = tree?.backgroundAudioURL else {
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
    func startVoiceOver() {
        // Attempt to play speech from audio file, if failed, resort to text-to-speech
        if !startVoiceOverAudio() {
            // Start text-to-speech instead
            startTextToSpeech()
        }
    }
    func stopVoiceOver() {
        stopVoiceOverAudio()
        stopTextToSpeech()
    }
    
    func startVoiceOverAudio() -> Bool {
        guard let voiceOverAudioURL = tree?.currentVoiceOverAudioURL else {
            return false
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOfURL: voiceOverAudioURL)
            
            // Set audio player delegate
            audioPlayer.delegate = self
            
            // Play
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            
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
    
    func startTextToSpeech() {
        guard let node = tree?.currentNode else {
            return
        }
        
        // Set speech synthesizer delegate to self
        speechSynthesizer.delegate = self
        
        var utterances: [AVSpeechUtterance] = []
        
        for module in node.modules where module is SpeakableTextTypeModule {
            let texts = (module as! SpeakableTextTypeModule).speakableTexts
            
            for text in texts {
                let utterance = AVSpeechUtterance(string: text)
                
                // Set last speech utterance
                lastSpeechUtterance = utterance
                
                utterances.append(utterance)
            }
        }
        
        // Speak utterrances
        utterances.forEach { self.speechSynthesizer.speakUtterance($0) }
    }
    func stopTextToSpeech() {
        if speechSynthesizer.speaking {
            speechSynthesizer.stopSpeakingAtBoundary(.Immediate)
        }
    }
    
    var shouldDismissWhenNextNodeIsEndState: Bool {
        return true
    }
}

// MARK: - Auto-play

extension TreeViewController {
    var autoPlay: Bool {
        get {
            // Default to true if not yet set
            let standardUserDefaults = NSUserDefaults.standardUserDefaults()
            if standardUserDefaults.objectForKey("UsbongKit.AutoPlayableTree.autoPlay") == nil {
                standardUserDefaults.setBool(false, forKey: "UsbongKit.AutoPlayableTree.autoPlay")
            }
            
            return standardUserDefaults.boolForKey("UsbongKit.AutoPlayableTree.autoPlay")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "UsbongKit.AutoPlayableTree.autoPlay")
            
            // If set to on/true, also turn on voice-over
            if newValue {
                voiceOverOn = true
            }
        }
    }
}

extension TreeViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        // If auto-play and is on last speech utterance, transition to next node
        if autoPlay && lastSpeechUtterance == utterance {
            transitionToNextNode()
        }
    }
}

extension TreeViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        // If auto-play and is on audio player finished successfully, and is voice over audio player
        if voiceOverAudioPlayer == player && autoPlay && flag {
            // Transition to next node
            transitionToNextNode()
        }
    }
}

