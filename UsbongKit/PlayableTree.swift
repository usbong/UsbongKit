//
//  PlayableTree.swift
//  UsbongKit
//
//  Created by Chris Amanse on 1/12/16.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation
import AVFoundation

public protocol PlayableTree: class {
    var nodeView: NodeView! { get set }
    var tree: UsbongTree? { get set }
    
    var voiceOverOn: Bool { get set }
    var speechSynthesizer: AVSpeechSynthesizer { get set }
    var backgroundAudioPlayer: AVAudioPlayer? { get set }
    var voiceOverAudioPlayer: AVAudioPlayer? { get set }
    
    // Node
    func reloadNode()
    func transitionToPreviousNode()
    func transitionToNextNode()
    
    // View controllers
    func showAvailableActions(sender: AnyObject?)
    func showChooseLanguageScreen()
    
    // Background audio
    func loadBackgroundAudio()
    
    // Voice-over
    func startVoiceOver()
    func stopVoiceOver()
    func startVoiceOverAudio() -> Bool
    func stopVoiceOverAudio()
    func startTextToSpeech()
    func stopTextToSpeech()
    
    // Dismiss
    /// If `true`, receiver is dismissed if next node is end state, otherwise, it shows end state.
    var shouldDismissWhenNextNodeIsEndState: Bool { get }
}

public extension PlayableTree where Self: UIViewController {
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
            return
        }
        
        // Dismiss if next node is not available
        if !tree.nextNodeIsAvailable {
            // Save state of last node
            tree.saveStateOfLastNode()
            
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        tree.transitionToNextNode()
        reloadNode()
    }
    
    func showAvailableActions(sender: AnyObject?) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Voice-over
        let speechText = "Speech " + (voiceOverOn ? "Off" : "On")
        let speechAction = UIAlertAction(title: speechText, style: .Default) { (action) -> Void in
            self.voiceOverOn = !self.voiceOverOn
        }
        actionController.addAction(speechAction)
        
        // Auto-play
        if let autoPlayableTree = self as? AutoPlayableTree {
            let autoPlayText = "Auto-play " + (autoPlayableTree.autoPlay ? "Off" : "On")
            
            let autoPlayAction = UIAlertAction(title: autoPlayText, style: .Default, handler: { action in
                autoPlayableTree.autoPlay = !autoPlayableTree.autoPlay
            })
            actionController.addAction(autoPlayAction)
        }
        
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
        if let tree = self.tree {
            let languagesTableVC = LanguagesTableViewController()
            let navVC = UINavigationController(rootViewController: languagesTableVC)
            
            languagesTableVC.languages = tree.availableLanguages
            languagesTableVC.selectedLanguage = tree.currentLanguage
            languagesTableVC.didSelectLanguageCompletion = { selectedLanguage in
                tree.currentLanguage = selectedLanguage
                
                self.reloadNode()
            }
            
            navVC.modalPresentationStyle = .FormSheet
            presentViewController(navVC, animated: true, completion: nil)
        }
    }
}

public extension PlayableTree {
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
        
        if let delegate = self as? HintsTextViewDelegate {
            nodeView.hintsTextViewDelegate = delegate
        }
        
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
        
        // Get coordinator if AutoPlayable
        let coordinator = (self as? AutoPlayableTree)?.voiceOverCoordinator
        coordinator?.delegate = self as? VoiceOverCoordinatorDelegate
        
        // Set speech synthesizer delegate to coordinator
        speechSynthesizer.delegate = coordinator
        
        for module in node.modules where module is SpeakableTextTypeModule {
            let texts = (module as! SpeakableTextTypeModule).speakableTexts
            
            for text in texts {
                let utterance = AVSpeechUtterance(string: text)
                
                utterance.voice = AVSpeechSynthesisVoice(language: "en-EN")
                
                coordinator?.lastSpeechUtterance = utterance
                
                // Speak
                speechSynthesizer.speakUtterance(utterance)
            }
        }
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
