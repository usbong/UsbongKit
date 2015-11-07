//
//  TaskNodeView.swift
//  UsbongKit
//
//  Created by Joe Amanse on 07/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

public class TaskNodeView: UIView {
    public var taskNodeTableView: UITableView = UITableView()
    public weak var hintsTextViewDelegate: HintsTextViewDelegate?
    
    public var taskNode: TaskNode = TaskNode(modules: []) {
        didSet {
            registerNibs()
            taskNodeTableView.reloadData()
        }
    }
    public var hintsDictionary: [String: String] = [String: String]()
    public var hintsColor = UIColor(red: 0.6, green: 0.56, blue: 0.36, alpha: 1)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        taskNodeTableView.frame = bounds
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Custom
    
    private func registerNibs() {
        let modules = taskNode.modules
        for module in modules {
            switch module {
            case is TextTaskNodeModule:
                taskNodeTableView.registerNib(UINib(nibName: "TextTableViewCell", bundle: NSBundle(forClass: TextTableViewCell.self)), forCellReuseIdentifier: "Text")
            case is ImageTaskNodeModule:
                taskNodeTableView.registerNib(UINib(nibName: "ImageTableViewCell", bundle: NSBundle(forClass: ImageTableViewCell.self)), forCellReuseIdentifier: "Image")
            default:
                break
            }
        }
    }
}

extension TaskNodeView: UITableViewDelegate {
    
}

extension TaskNodeView: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Allow calculated height of image
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskNode.modules.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            
            textCell.titleTextView.attributedText = attributedText.attributedStringWithHints(hintsDictionary, withColor: hintsColor)
            textCell.titleTextView.hintsTextViewDelegate = hintsTextViewDelegate
            
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
}

//extension TaskNodeView: HintsTextViewDelegate {
//    public func hintsTextView(textView: HintsTextView, didTapString: String, withHint hint: String) {
//        let alertController = UIAlertController(title: "Word Hint", message: hint, preferredStyle: .Alert)
//        
//        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//        
//        alertController.addAction(okAction)
//    }
//}
