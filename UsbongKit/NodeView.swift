import UIKit

public class NodeView: UIView {
    public let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.Plain)
    private let backgroundImageView = UIImageView(frame: CGRect.zero)
    
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
    public var hintsDictionary: [String: String] = [:]
    public var hintsColor = UIColor(red: 0.6, green: 0.56, blue: 0.36, alpha: 1)
    public weak var hintsTextViewDelegate: HintsTextViewDelegate?
    
    // MARK: Background image
    public var backgroundImage: UIImage? {
        get {
            return backgroundImageView.image
        }
        set {
            backgroundImageView.image = newValue
        }
    }
    
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
    
    func didUpdateDatePicker(sender: UIDatePicker) {
        guard let dateNode = node as? DateNode else { return }
        
        dateNode.date = sender.date
    }
}

extension NodeView: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return node.modules.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let modules = node.modules
        if let listModule = modules[section] as? OptionsTypeModule {
            return listModule.options.count
        }
        
        return 1
    }
    
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
            reusedCell.datePicker.addTarget(self, action: Selector("didUpdateDatePicker:"), forControlEvents: .ValueChanged)
            
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

extension NodeView: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectionModule = node.modules[indexPath.section] as? SelectionTypeModule {
            selectionModule.toggleIndex(indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    // Allow calculated height of image
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let module = node.modules[indexPath.section]
        switch module {
        case let imageModule as ImageModule:
            guard let originalSize = imageModule.image?.size else {
                return UITableViewAutomaticDimension
            }
            
            let width = tableView.bounds.width
            let aspectRatio = width / originalSize.width
            let height = aspectRatio * originalSize.height
            
            return height
        default:
            return UITableViewAutomaticDimension
        }
    }
}

extension NodeView: UITextFieldDelegate {
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

extension NodeView: UITextViewDelegate {
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
