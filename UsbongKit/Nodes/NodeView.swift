//
//  NodeView.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Renders the view for a `Node`
public class NodeView: UIView {
    public let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.Plain)
    
    private let backgroundImageView = UIImageView(frame: CGRect.zero)
    
    /// The node to be rendered. Default is a `TextNode` with text "No Node".
    public var node: Node = TextNode(text: "No Node") {
        didSet {
            tableView.reloadData()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        sharedInitialization()
    }
    
    public override func awakeFromNib() {
        sharedInitialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Configuration for initialization, and addition of subviews
    private func sharedInitialization() {
        // Background image view
        backgroundImageView.frame = bounds
        backgroundImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundImageView.backgroundColor = UIColor.clearColor()
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        addSubview(backgroundImageView)
        
        // Table view
        tableView.frame = bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // Resize with superview
        tableView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(tableView)
        
        tableView.registerReusableCell(TextTableViewCell)
        tableView.registerReusableCell(ImageTableViewCell)
        tableView.registerReusableCell(RadioTableViewCell)
        tableView.registerReusableCell(CheckboxTableViewCell)
        tableView.registerReusableCell(TextFieldTableViewCell)
        tableView.registerReusableCell(TextAreaTableViewCell)
        tableView.registerReusableCell(DateTableViewCell)
    }
    
    // MARK: Hints dictionary
    
    /// The hints dictionary to be used for the `TextModule`, where the key is the word or phrase, and the value is its definition
    public var hintsDictionary: [String: String] = [:]
    
    /// The font color for the word hint
    public var hintsColor = UIColor(red: 0.6, green: 0.56, blue: 0.36, alpha: 1)
    
    /// The delegate for the hints text view, where it handles the tapping of a word hint
    public weak var hintsTextViewDelegate: HintsTextViewDelegate?
    
    // MARK: Background image
    
    /// The background image for the `NodeView`
    public var backgroundImage: UIImage? {
        get {
            return backgroundImageView.image
        }
        set {
            backgroundImageView.image = newValue
        }
    }
    
    /// Gets the text attributes (formatting) for a module
    func textAttributesForModule(module: Module) -> [String: AnyObject] {
        let fontSize: CGFloat
        if traitCollection.horizontalSizeClass == .Regular && traitCollection.verticalSizeClass == .Regular {
            fontSize = 42
        } else {
            fontSize = 21
        }
        
        let font = UIFont.systemFontOfSize(fontSize)
        let textColor = UIColor.blackColor()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = module is TextModule ? .Center : .Left
        
        return [NSForegroundColorAttributeName: textColor, NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
    }
    
    /// Called when the date of the date picker for the `DateNode` is changed
    func didUpdateDatePicker(sender: UIDatePicker) {
        guard let dateNode = node as? DateNode else { return }
        
        dateNode.date = sender.date
    }
}

// A collection of functions to display data in the table view
extension NodeView: UITableViewDataSource {
    /// The number of sections of the table is based on the number of modules of the node
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return node.modules.count
    }
    
    /// The number of rows in a section is usually one. But for an `OptionsTypeModule` (where modules are lists), it is the number of options/items
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let modules = node.modules
        if let listModule = modules[section] as? OptionsTypeModule {
            return listModule.options.count
        }
        
        return 1
    }
    
    /// Returns the cell for a row. This is where the views for modules are determined.
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let module = node.modules[indexPath.section]
        
        let cell: UITableViewCell
        
        switch module {
        case let textModule as TextModule:
            let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as TextTableViewCell
            
            let attributedText = NSMutableAttributedString(string: textModule.text)
            attributedText.addAttributes(textAttributesForModule(textModule), range: NSRange(location: 0, length: attributedText.length))
            
            reusedCell.titleTextView.attributedText = attributedText.attributedStringWithHints(hintsDictionary, withColor: hintsColor)
            reusedCell.titleTextView.hintsTextViewDelegate = hintsTextViewDelegate
            
            cell = reusedCell
        case let imageModule as ImageModule:
            let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as ImageTableViewCell
            reusedCell.customImageView.image = imageModule.image
            
            cell = reusedCell
        case let radioButtonsModule as RadioButtonsModule:
            let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as RadioTableViewCell
            
            reusedCell.titleLabel.text = radioButtonsModule.options[indexPath.row]
            reusedCell.radioButtonSelected = (indexPath.row == radioButtonsModule.selectedIndex)
            
            cell = reusedCell
        case let checkboxesModule as CheckboxesModule:
            let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as CheckboxTableViewCell
            reusedCell.titleLabel.text = checkboxesModule.options[indexPath.row]
            reusedCell.checkboxButtonSelected = checkboxesModule.selectedIndices.contains(indexPath.row)
            
            cell = reusedCell
        case let listModule as ListModule:
            let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as TextTableViewCell

            let attributedText = NSMutableAttributedString(string: listModule.options[indexPath.row])
            attributedText.addAttributes(textAttributesForModule(listModule), range: NSRange(location: 0, length: attributedText.length))
            
            reusedCell.titleTextView.attributedText = attributedText
            
            cell = reusedCell
        case let textInputModule as TextInputModule:
            let type = textInputModule.type
            let attributedText = NSMutableAttributedString(string: textInputModule.textInput)
            attributedText.addAttributes(textAttributesForModule(textInputModule), range: NSRange(location: 0, length: attributedText.length))
            
            switch type {
            case .SingleLine, .SingleLineNumerical:
                let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as TextFieldTableViewCell
                
                reusedCell.textField.attributedText = attributedText
                reusedCell.textField.delegate = self
                
                if type == .SingleLineNumerical {
                    reusedCell.textField.keyboardType = .DecimalPad
                    reusedCell.textField.inputAccessoryView = reusedCell.keyboardAccessoryView
                } else {
                    reusedCell.textField.keyboardType = .Default
                    reusedCell.textField.inputAccessoryView = nil
                }
                
                cell = reusedCell
            case .MultipleLine:
                let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as TextAreaTableViewCell
                
                reusedCell.textView.attributedText = attributedText
                reusedCell.textView.delegate = self
                
                cell = reusedCell
            }
        case let dateModule as DateModule:
            let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as DateTableViewCell
            
            reusedCell.datePicker.date = dateModule.date
            reusedCell.datePicker.addTarget(self, action: #selector(NodeView.didUpdateDatePicker(_:)), forControlEvents: .ValueChanged)
            
            cell = reusedCell
        default:
            if let reusedCell = tableView.dequeueReusableCellWithIdentifier("defaultCell") {
                cell = reusedCell
            } else {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "defaultCell")
            }
            
            cell.textLabel?.text = "Unknown Module"
        }
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
}

// A collection of functions to handle table view events
extension NodeView: UITableViewDelegate {
    /// This function is called when a row is selected. It is used for a `SelectionTypeModule`, which is used for radio buttons, and checkboxes
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectionModule = node.modules[indexPath.section] as? SelectionTypeModule {
            selectionModule.toggleIndex(indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    /// This function is where the height of an image is calculated since images for the ImageModule are made to fit the width of the view, while maintaining its aspect ratio
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let module = node.modules[indexPath.section]
        switch module {
        case let imageModule as ImageModule:
            // Calculate height for the image module
            guard let originalSize = imageModule.image?.size else {
                return UITableViewAutomaticDimension
            }
            
            let width = tableView.bounds.width
            let aspectRatio = width / originalSize.width
            let height = aspectRatio * originalSize.height
            
            return height
        default:
            // Default is an automatic height which the `UITableView` calculates based on the cell's constraints
            return UITableViewAutomaticDimension
        }
    }
}

// A collection of functions to handle text field events
extension NodeView: UITextFieldDelegate {
    /// This function is called every time the text is changed in a text field of a text input type node. It updates the text property of the node.
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let currentNode = node as? TextInputTypeNode else {
            return true
        }
        guard let currentText = textField.text else {
            return true
        }
        
        // Update text input of current node
        let finalText = NSString(string: currentText).stringByReplacingCharactersInRange(range, withString: string)
        currentNode.textInput = finalText
        
        return true
    }
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// A collection of functions to handle text view events
extension NodeView: UITextViewDelegate {
    /// This function is called every time the text is changed in a text field of a text input type node. It updates the text property of the node.
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let currentNode = node as? TextInputTypeNode else {
            return true
        }
        guard let currentText = textView.text else {
            return true
        }
        
        // Update text input of current node
        let finalText = NSString(string: currentText).stringByReplacingCharactersInRange(range, withString: text)
        currentNode.textInput = finalText
        
        return true
    }
}
