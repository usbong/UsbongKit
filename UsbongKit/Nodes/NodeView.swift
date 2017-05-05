//
//  NodeView.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Renders the view for a `Node`
open class NodeView: UIView {
    open let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    fileprivate let backgroundImageView = UIImageView(frame: CGRect.zero)
    
    /// The node to be rendered. Default is a `TextNode` with text "No Node".
    open var node: Node = TextNode(text: "No Node") {
        didSet {
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        sharedInitialization()
    }
    
    open override func awakeFromNib() {
        sharedInitialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Configuration for initialization, and addition of subviews
    fileprivate func sharedInitialization() {
        // Background image view
        backgroundImageView.frame = bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.backgroundColor = UIColor.clear
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        addSubview(backgroundImageView)
        
        // Table view
        tableView.frame = bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Resize with superview
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(tableView)
        
        tableView.registerReusableCell(TextTableViewCell.self)
        tableView.registerReusableCell(ImageTableViewCell.self)
        tableView.registerReusableCell(RadioTableViewCell.self)
        tableView.registerReusableCell(CheckboxTableViewCell.self)
        tableView.registerReusableCell(TextFieldTableViewCell.self)
        tableView.registerReusableCell(TextAreaTableViewCell.self)
        tableView.registerReusableCell(DateTableViewCell.self)
    }
    
    // MARK: Hints dictionary
    
    /// The hints dictionary to be used for the `TextModule`, where the key is the word or phrase, and the value is its definition
    open var hintsDictionary: [String: String] = [:]
    
    /// The font color for the word hint
    open var hintsColor = UIColor(red: 0.6, green: 0.56, blue: 0.36, alpha: 1)
    
    /// The delegate for the hints text view, where it handles the tapping of a word hint
    open weak var hintsTextViewDelegate: HintsTextViewDelegate?
    
    // MARK: Background image
    
    /// The background image for the `NodeView`
    open var backgroundImage: UIImage? {
        get {
            return backgroundImageView.image
        }
        set {
            backgroundImageView.image = newValue
        }
    }
    
    /// Gets the text attributes (formatting) for a module
    func textAttributesForModule(_ module: Module) -> [String: AnyObject] {
        let fontSize: CGFloat
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            fontSize = 42
        } else {
            fontSize = 21
        }
        
        let font = UIFont.systemFont(ofSize: fontSize)
        let textColor = UIColor.black
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = module is TextModule ? .center : .left
        
        return [NSForegroundColorAttributeName: textColor, NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
    }
    
    /// Called when the date of the date picker for the `DateNode` is changed
    func didUpdateDatePicker(_ sender: UIDatePicker) {
        guard let dateNode = node as? DateNode else { return }
        
        dateNode.date = sender.date
    }
}

// A collection of functions to display data in the table view
extension NodeView: UITableViewDataSource {
    /// The number of sections of the table is based on the number of modules of the node
    public func numberOfSections(in tableView: UITableView) -> Int {
        return node.modules.count
    }
    
    /// The number of rows in a section is usually one. But for an `OptionsTypeModule` (where modules are lists), it is the number of options/items
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let modules = node.modules
        if let listModule = modules[section] as? OptionsTypeModule {
            return listModule.options.count
        }
        
        return 1
    }
    
    /// Returns the cell for a row. This is where the views for modules are determined.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            case .singleLine, .singleLineNumerical:
                let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as TextFieldTableViewCell
                
                reusedCell.textField.attributedText = attributedText
                reusedCell.textField.delegate = self
                
                if type == .singleLineNumerical {
                    reusedCell.textField.keyboardType = .decimalPad
                    reusedCell.textField.inputAccessoryView = reusedCell.keyboardAccessoryView
                } else {
                    reusedCell.textField.keyboardType = .default
                    reusedCell.textField.inputAccessoryView = nil
                }
                
                cell = reusedCell
            case .multipleLine:
                let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as TextAreaTableViewCell
                
                reusedCell.textView.attributedText = attributedText
                reusedCell.textView.delegate = self
                
                cell = reusedCell
            }
        case let dateModule as DateModule:
            let reusedCell = tableView.dequeueReusableCell(indexPath: indexPath) as DateTableViewCell
            
            reusedCell.datePicker.date = dateModule.date
            reusedCell.datePicker.addTarget(self, action: #selector(NodeView.didUpdateDatePicker(_:)), for: .valueChanged)
            
            cell = reusedCell
        default:
            if let reusedCell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") {
                cell = reusedCell
            } else {
                cell = UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
            }
            
            cell.textLabel?.text = "Unknown Module"
        }
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}

// A collection of functions to handle table view events
extension NodeView: UITableViewDelegate {
    /// This function is called when a row is selected. It is used for a `SelectionTypeModule`, which is used for radio buttons, and checkboxes
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectionModule = node.modules[indexPath.section] as? SelectionTypeModule {
            selectionModule.toggleIndex(indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    /// This function is where the height of an image is calculated since images for the ImageModule are made to fit the width of the view, while maintaining its aspect ratio
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentNode = node as? TextInputTypeNode else {
            return true
        }
        guard let currentText = textField.text else {
            return true
        }
        
        // Update text input of current node
        let finalText = NSString(string: currentText).replacingCharacters(in: range, with: string)
        currentNode.textInput = finalText
        
        return true
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// A collection of functions to handle text view events
extension NodeView: UITextViewDelegate {
    /// This function is called every time the text is changed in a text field of a text input type node. It updates the text property of the node.
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentNode = node as? TextInputTypeNode else {
            return true
        }
        guard let currentText = textView.text else {
            return true
        }
        
        // Update text input of current node
        let finalText = NSString(string: currentText).replacingCharacters(in: range, with: text)
        currentNode.textInput = finalText
        
        return true
    }
}
