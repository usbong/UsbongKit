//
//  NodeViewController.swift
//  NodeKit
//
//  Created by Chris Amanse on 12/24/15.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import AVFoundation
import UsbongKit

class NodeViewController: UIViewController {
    @IBOutlet weak var nodeView: NodeView!
    
    var node: Node = TextNode(text: "No Node")
    var speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeView.node = node
        
        startTextToSpeech()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        stopTextToSpeech()
    }
    
    func startTextToSpeech() {
        for module in node.modules where module is SpeakableTextTypeModule {
            let texts = (module as! SpeakableTextTypeModule).speakableTexts
            
            for text in texts {
                let utterance = AVSpeechUtterance(string: text)
                
                utterance.voice = AVSpeechSynthesisVoice(language: "en-EN")
                
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
}

