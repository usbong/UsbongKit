//
//  TaskNodeView.swift
//  UsbongKit
//
//  Created by Joe Amanse on 07/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

public class TaskNodeView: UIView {
    public var backgroundImageView: UIImageView = UIImageView(frame: CGRect.zero)
    public var taskNodeTableView: UITableView = UITableView(frame: CGRect.zero, style: .Plain)
    public weak var hintsTextViewDelegate: HintsTextViewDelegate?
    
    public var taskNode: TaskNode = TaskNode(modules: []) {
        didSet {
            registerNibs()
            taskNodeTableView.reloadData()
        }
    }
    public var hintsDictionary: [String: String] = [String: String]()
    public var hintsColor = UIColor(red: 0.6, green: 0.56, blue: 0.36, alpha: 1)
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        customInitialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override func awakeFromNib() {
        customInitialization()
    }
    
    private func customInitialization() {
        // Background image view properties
        backgroundImageView.backgroundColor = UIColor.clearColor()
        backgroundImageView.contentMode = .ScaleAspectFill
        
        // Table view properties
        taskNodeTableView.backgroundColor = UIColor.clearColor()
        taskNodeTableView.separatorStyle = .None
        
        // Table view self-sizing height
        taskNodeTableView.rowHeight = UITableViewAutomaticDimension
        taskNodeTableView.estimatedRowHeight = 100
        
        addBackgroundImageView()
        addTaskNodeTableView()
    }
    private func addBackgroundImageView() {
        addSubview(backgroundImageView)
        
        // Setup constraints
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        let viewsDictionary: [String: AnyObject] = ["view" : backgroundImageView]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
    
    private func addTaskNodeTableView() {
        addSubview(taskNodeTableView)
        
        // Setup constraints
        taskNodeTableView.translatesAutoresizingMaskIntoConstraints = false
        let viewsDictionary: [String: AnyObject] = ["tableView" : taskNodeTableView]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        // Add constraints
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
        
        // Add data source and delegate
        taskNodeTableView.dataSource = self
        taskNodeTableView.delegate = self
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
            case is LinkTaskNodeModule:
                taskNodeTableView.registerNib(UINib(nibName: "LinkTableViewCell", bundle: NSBundle(forClass: LinkTableViewCell.self)), forCellReuseIdentifier: "Link")
            default:
                break
            }
        }
    }
}

extension TaskNodeView: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let linkTaskNode = taskNode as? LinkTaskNode {
            linkTaskNode.currentSelectedIndex = indexPath.row - linkTaskNode.indexOffset
            tableView.reloadData()
        }
    }
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
                let width = tableView.bounds.width
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
            
            imageCell.customImageView.image = UIImage(contentsOfFile: imageModule.imageFilePath)
            
            cell = imageCell
        case let linkModule as LinkTaskNodeModule:
            let linkCell = tableView.dequeueReusableCellWithIdentifier("Link") as! LinkTableViewCell
            
            var selected = false
            if let linkTaskNode = taskNode as? LinkTaskNode {
                if indexPath.row == linkTaskNode.trueIndex {
                    selected = true
                }
            }
            linkCell.radioButtonSelected = selected
            
            linkCell.titleLabel.text = linkModule.taskValue
            
            cell = linkCell
        default:
            cell = UITableViewCell(style: .Default, reuseIdentifier: "unknownModule")
            cell.textLabel?.text = "Unkown"
        }
        
        // Set cell background color equal to content view background color due to iPad cell background bug
        cell.backgroundColor = cell.contentView.backgroundColor
        
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
