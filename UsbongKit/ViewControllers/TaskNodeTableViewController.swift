//
//  TaskNodeTableViewController.swift
//  usbong
//
//  Created by Chris Amanse on 17/09/2015.
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

public class TaskNodeTableViewController: UITableViewController {
    public var taskNode: TaskNode = TaskNode(modules: []) {
        didSet {
            registerNibs()
            tableView.reloadData()
        }
    }
    public var hintsDictionary: [String: String] = [String: String]()
    
    public var backgroundAudioPlayer: AVAudioPlayer?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Register nibs
        registerNibs()
        
        view.backgroundColor = UIColor.clearColor()
        
        // Table view properties
        tableView.separatorStyle = .None
        
        // Table view self-sizing height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom
    
    private func registerNibs() {
        let modules = taskNode.modules
        for module in modules {
            switch module {
            case is TextTaskNodeModule:
                tableView.registerNib(UINib(nibName: "TextTableViewCell", bundle: NSBundle(forClass: TextTableViewCell.self)), forCellReuseIdentifier: "Text")
            case is ImageTaskNodeModule:
                tableView.registerNib(UINib(nibName: "ImageTableViewCell", bundle: NSBundle(forClass: ImageTableViewCell.self)), forCellReuseIdentifier: "Image")
            default:
                break
            }
        }
    }

    // MARK: - Table view data source
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Allow calculated height of image
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let module = taskNode.modules[indexPath.row]
        switch module {
        case let imageModule as ImageTaskNodeModule:
            if let originalSize = UIImage(contentsOfFile: imageModule.imageFilePath)?.size {
                let width = UIScreen.mainScreen().bounds.width
                let aspectRatio = width / originalSize.width
                let height = aspectRatio * originalSize.height
                
                return height
            }
            return UITableViewAutomaticDimension
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskNode.modules.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        // Figures out what type of TaskNodeModule, and loads the appropriate cell (text = text cell, image = image cell, etc.)
        let module = taskNode.modules[indexPath.row]
        switch module {
        case let textModule as TextTaskNodeModule:
            let textCell = tableView.dequeueReusableCellWithIdentifier("Text", forIndexPath: indexPath) as! TextTableViewCell
            print("Text: \(textModule.text)")
            
            // Add hints if available
            let attributedText = NSMutableAttributedString(string: textModule.text)
            
            let font = UIFont.systemFontOfSize(21)
            let textColor = UIColor.blackColor()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .Center
            
            let textAttributes: [String: AnyObject] = [NSForegroundColorAttributeName: textColor, NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
            attributedText.addAttributes(textAttributes, range: NSRange(location: 0, length: attributedText.length))
            
            textCell.titleTextView.attributedText = attributedText.attributedStringWithHints(hintsDictionary)
            textCell.titleTextView.hintsTextViewDelegate = self
            
            cell = textCell
        case let imageModule as ImageTaskNodeModule:
            let imageCell = tableView.dequeueReusableCellWithIdentifier("Image", forIndexPath: indexPath) as! ImageTableViewCell
            print("Image: \(imageModule.imageFilePath)")
            imageCell.customImageView.image = UIImage(contentsOfFile: imageModule.imageFilePath)
            
            cell = imageCell
        default:
            cell = UITableViewCell(style: .Default, reuseIdentifier: "unknownModule")
            cell.textLabel?.text = "Unkown"
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TaskNodeTableViewController: HintsTextViewDelegate {
    public func hintsTextView(textView: HintsTextView, didTapString: String, withHint hint: String) {
        let alertController = UIAlertController(title: "Word Hint", message: hint, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
