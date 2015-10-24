//
//  TreeViewController.swift
//  usbong
//
//  Created by Chris Amanse on 9/15/15.
//  Copyright 2015 Usbong Social Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import AVFoundation

// Root view controller for Tree (Page-based)
// TODO: Place string literals as constants in a class (Global if it will be used throughout the project, or local if used only here). Do this after finalizing UI of app
class TreeViewController: UIViewController {
    static func loadFromStoryboard() -> UINavigationController {
        return UIStoryboard(name: "TreeStoryboard", bundle: NSBundle(forClass: self)).instantiateInitialViewController() as! UINavigationController
    }
    
    var treeZipURL: NSURL?
    
    var taskNodeGenerator: UsbongTaskNodeGenerator?
    
    var taskNodeTableViewController = TaskNodeTableViewController()
    
    lazy var speechSynthezier: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var audioSpeechPlayer: AVAudioPlayer?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backNextSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Unpack tree (place this on a background thread if noticeable lag occurs)
        if let zipURL = treeZipURL {
            if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToTemporaryDirectoryWithTreeURL(zipURL) {
                taskNodeGenerator = UsbongTaskNodeGeneratorXML(treeRootURL: treeRootURL)
                
                navigationItem.title = taskNodeGenerator?.title
            }
        }
        
        if let firstTaskNode = taskNodeGenerator?.currentTaskNode {
            taskNodeTableViewController.taskNode = firstTaskNode
            
            addChildViewController(taskNodeTableViewController)
            containerView.addSubview(taskNodeTableViewController.view)
            
            taskNodeTableViewController.view.frame = containerView.bounds
            taskNodeTableViewController.didMoveToParentViewController(self)
            
            activityIndicatorView.stopAnimating()
            
            // Load background audio at start
            loadBackgroundAudio()
        }
        
        if taskNodeGenerator?.previousTaskNode == nil {
            backNextSegmentedControl.setTitle("Exit", forSegmentAtIndex: 0)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If no task nodes, show alert
        if taskNodeGenerator?.taskNodesCount ?? 0 == 0 {
            print("No task nodes found!")
            
            let alertController = UIAlertController(title: "Invalid Tree", message: "This tree can't be opened by the app.", preferredStyle: .Alert)
            
            let closeAction = UIAlertAction(title: "Close", style: .Destructive, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            alertController.addAction(closeAction)
            
            presentViewController(alertController, animated: true, completion: nil)
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
    
    @IBAction func didPressPreviousOrNext(sender: UISegmentedControl) {
        stopVoiceOver()
        
        // Before transition
        if sender.selectedSegmentIndex == 0 {
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
        
        // Load task node it task node table view controller
//        if let currentTaskNode = taskNodeGenerator?.currentTaskNode {
//            let oldTaskNode = taskNodeTableViewController.taskNode
//            taskNodeTableViewController.taskNode = currentTaskNode
//            
//            // Background audio
//            if oldTaskNode.backgroundAudioFilePath != currentTaskNode.backgroundAudioFilePath {
//                backgroundAudioPlayer = nil
//                loadBackgroundAudio()
//            }
//        }
        reloadCurrentTaskNode()
        
        // Finished transition
        // Change back button title to exit if there are no previous task nodes
        if taskNodeGenerator?.previousTaskNode == nil {
            sender.setTitle("Exit", forSegmentAtIndex: 0)
        } else {
            sender.setTitle("Back", forSegmentAtIndex: 0)
        }
        
        // Change next button title to exit if transitioned node is end state
        if taskNodeGenerator?.currentTaskNode is EndStateTaskNode {
            sender.setTitle("Exit", forSegmentAtIndex: 1)
        } else {
            sender.setTitle("Next", forSegmentAtIndex: 1)
        }
    }
    
    @IBAction func didPressExit(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressMore(sender: AnyObject) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let speechAction = UIAlertAction(title: "Speech", style: .Default) { (action) -> Void in
            self.startVoiceOver()
        }
        let setLanguageAction = UIAlertAction(title: "Set Language", style: .Default) { (action) -> Void in
            self.showChoosLanguageScreen()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionController.addAction(speechAction)
        actionController.addAction(setLanguageAction)
        actionController.addAction(cancelAction)
        
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    // MARK: - Custom
    
    func reloadCurrentTaskNode() {
        if let currentTaskNode = taskNodeGenerator?.currentTaskNode {
            taskNodeTableViewController.taskNode = currentTaskNode
            
            // Background audio - change only if not empty and different
            if let taskNodeBGFilePath = currentTaskNode.backgroundAudioFilePath {
                let currentBGFilePath = backgroundAudioPlayer?.url?.path ?? ""
                if taskNodeBGFilePath.characters.count > 0 && taskNodeBGFilePath != currentBGFilePath {
                    backgroundAudioPlayer = nil
                    loadBackgroundAudio()
                }
            }
        }
    }
    
    // MARK: Background Audio
    
    func loadBackgroundAudio() {
        if let currentTaskNode = taskNodeGenerator?.currentTaskNode {
            if let backgroundAudopFilePath = currentTaskNode.backgroundAudioFilePath {
                if let audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: backgroundAudopFilePath)) {
                    audioPlayer.numberOfLoops = -1 // Endless loop
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    audioPlayer.volume = 0.3
                    
                    backgroundAudioPlayer = audioPlayer
                }
            }
        }
    }
    
    // MARK: Voice-over
    func startVoiceOver() {
        if let currentTaskNode = taskNodeGenerator?.currentTaskNode {
            // Attempt to play speech from audio file, if failed, resort to text-to-speech
            if !startAudioSpeechInTaskNode(currentTaskNode) {
                print(">>> Text-to-speech")
                startTextToSpeechInTaskNode(currentTaskNode)
            }
        }
    }
    func stopVoiceOver() {
        stopTextToSpeech()
        stopAudioSpeech()
    }
    
    func startTextToSpeechInTaskNode(taskNode: TaskNode) {
        let modules = taskNode.modules
        for module in modules {
            if let textModule = module as? TextTaskNodeModule {
                print("\(textModule.text)")
                let utterance = AVSpeechUtterance(string: textModule.text)
                
                // TODO: Set voice with language
                utterance.voice = AVSpeechSynthesisVoice(language: taskNodeGenerator?.currentLanguageCode ?? "en-EN")
                
                // Speak
                speechSynthezier.speakUtterance(utterance)
            }
        }
    }
    func stopTextToSpeech() {
        if speechSynthezier.speaking {
            speechSynthezier.stopSpeakingAtBoundary(.Immediate)
        }
    }
    
    func startAudioSpeechInTaskNode(taskNode: TaskNode) -> Bool {
        if let audioFilePath = taskNode.audioFilePath {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioFilePath))
                
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                audioSpeechPlayer = audioPlayer
                print(">>> Played Audio File")
                return true
            } catch let error as NSError {
                print("Error loading audio file: \(error)")
                return false
            }
        }
        return false
    }
    func stopAudioSpeech() {
        if let player = audioSpeechPlayer {
            if player.playing {
                player.stop()
            }
        }
    }
    
    // MARK: Translation
    
    func showChoosLanguageScreen() {
        print(">>> Show choose language screen")
        
        // Create languages view controller
        let languagesVC = LanguagesTableViewController()
        languagesVC.treeViewController = self
        
        // Embed in navigation controller
        let navigationController = UINavigationController(rootViewController: languagesVC)
        
        presentViewController(navigationController, animated: true, completion: nil)
        
//        performSegueWithIdentifier("showLanguages", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLanguages" {
            if let languagesVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? LanguagesTableViewController {
                languagesVC.treeViewController = self
            }
        }
    }
}