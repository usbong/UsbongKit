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
    
    var treeURL: URL?
    var treeRootURL: URL?
    
    var speechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var voiceOverAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeView.node = TextNode(text: "Loading Tree...")
        nodeView.hintsColor = UIColor.darkGray
        
        // Do any additional setup after loading the view.
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
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
            
            //added by Mike, 20160114
            // Customize first language
            tree?.currentLanguage = "Filipino"
            
            // Save tree to self in main thread
            DispatchQueue.main.async {
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
    
    @IBAction func didPressExit(_ sender: AnyObject) {
        print("Did Press Exit")
        dismiss(animated: true, completion: nil)
        stopVoiceOver()
    }
    
    @IBAction func didPressMore(_ sender: AnyObject) {
        print("Did Press More")
        
        showAvailableActions(sender)
    }
    
    @IBAction func didPressPrevious(_ sender: AnyObject) {
        print("Did Press Previous")
        
        transitionToPreviousNode()
    }
    
    @IBAction func didPressNext(_ sender: AnyObject) {
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
            dismiss(animated: true, completion: nil)
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
            let alertController = UIAlertController(title: "No Selection", message: "Please select one of the choices", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okayAction)
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        // Dismiss if next node is end state and if PlayableTree says it should dismiss when next node is end state
        if tree.nextNodeIsEndState && shouldDismissWhenNextNodeIsEndState {
            // Save state of last node
            tree.saveStateOfLastNode()
            
            dismiss(animated: true, completion: nil)
            stopVoiceOver()
            return
        }
        
        // Dismiss if next node is not available
        if !tree.nextNodeIsAvailable {
            // Save state of last node
            tree.saveStateOfLastNode()
            
            dismiss(animated: true, completion: nil)
            stopVoiceOver()
            return
        }
        
        tree.transitionToNextNode()
        reloadNode()
    }
    
    func showAvailableActions(_ sender: AnyObject?) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Speak
        let speakText = "Speak"
        let speakAction = UIAlertAction(title: speakText, style: .default) { _ in
            self.stopVoiceOver()
            self.startVoiceOver()
        }
        actionController.addAction(speakAction)
        
        // Voice-over
        let autoSpeakText = "Turn Auto-Speak " + (voiceOverOn ? "Off" : "On")
        let autoSpeakAction = UIAlertAction(title: autoSpeakText, style: .default) { (action) -> Void in            self.voiceOverOn = !self.voiceOverOn
        }
        actionController.addAction(autoSpeakAction)
        
        // Auto-play
        let autoPlayText = "Auto-play " + (autoPlay ? "Off" : "On")
        
        let autoPlayAction = UIAlertAction(title: autoPlayText, style: .default, handler: { action in
            self.autoPlay = !self.autoPlay
        })
        
        actionController.addAction(autoPlayAction)
        
        // Set Language
        let setLanguageAction = UIAlertAction(title: "Set Language", style: .default) { (action) -> Void in
            self.showChooseLanguageScreen()
        }
        actionController.addAction(setLanguageAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionController.addAction(cancelAction)
        
        // For iPad action sheet behavior (similar to a popover)
        if let popover = actionController.popoverPresentationController {
            if let barButtonItem = sender as? UIBarButtonItem {
                popover.barButtonItem = barButtonItem
            } else if let view = sender as? UIView {
                popover.sourceView = view
            }
        }
        
        present(actionController, animated: true, completion: nil)
    }
    
    func showChooseLanguageScreen() {
        guard tree != nil else { return }
        
        performSegue(withIdentifier: "showLanguages", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showLanguages":
            guard let tree = self.tree else {
                break
            }
            
            let destinationViewController = (segue.destination as! UINavigationController).topViewController as! LanguagesTableViewController
            
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
            let standardUserDefaults = UserDefaults.standard
            if standardUserDefaults.object(forKey: "SpeechOn") == nil {
                standardUserDefaults.set(true, forKey: "SpeechOn")
            }
            return standardUserDefaults.bool(forKey: "SpeechOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SpeechOn")
            
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
                if newURL as URL != currentURL {
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
            let audioPlayer = try AVAudioPlayer(contentsOf: url as URL)
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
            let audioPlayer = try AVAudioPlayer(contentsOf: voiceOverAudioURL as URL)
            
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
        
        if audioPlayer.isPlaying {
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
        utterances.forEach { self.speechSynthesizer.speak($0) }
    }
    func stopTextToSpeech() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
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
            let standardUserDefaults = UserDefaults.standard
            if standardUserDefaults.object(forKey: "UsbongKit.AutoPlayableTree.autoPlay") == nil {
                standardUserDefaults.set(false, forKey: "UsbongKit.AutoPlayableTree.autoPlay")
            }
            
            return standardUserDefaults.bool(forKey: "UsbongKit.AutoPlayableTree.autoPlay")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UsbongKit.AutoPlayableTree.autoPlay")
            
            // If set to on/true, also turn on voice-over
            if newValue {
                voiceOverOn = true
            }
        }
    }
}

extension TreeViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // If auto-play and is on last speech utterance, transition to next node
        if autoPlay && lastSpeechUtterance == utterance {
            transitionToNextNode()
        }
    }
}

extension TreeViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // If auto-play and is on audio player finished successfully, and is voice over audio player
        if voiceOverAudioPlayer == player && autoPlay && flag {
            // Transition to next node
            transitionToNextNode()
        }
    }
}

