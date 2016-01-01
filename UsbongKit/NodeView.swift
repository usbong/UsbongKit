import UIKit

public class NodeView: UIView {
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.Plain)
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
        
        let nibsWithIdentifiers = [
            "Text": UINib(nibName: "TextTableViewCell", bundle: NSBundle(forClass: TextTableViewCell.self)),
            "Image": UINib(nibName: "ImageTableViewCell", bundle: NSBundle(forClass: ImageTableViewCell.self)),
            "Radio": UINib(nibName: "RadioTableViewCell", bundle: NSBundle(forClass: RadioTableViewCell.self)),
            "Checkbox": UINib(nibName: "CheckboxTableViewCell", bundle: NSBundle(forClass: CheckboxTableViewCell.self))
        ]
        registerNibsWithIdentifiers(nibsWithIdentifiers)
    }
    
    // MARK: Reusable Nibs
    private func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    private func registerNibsWithIdentifiers(nibsWithIdentifiers: [String: UINib?]) {
        for (identifier, nib) in nibsWithIdentifiers {
            registerNib(nib, forCellReuseIdentifier: identifier)
        }
    }
    
    // MARK: Background image
    public var backgroundImage: UIImage? {
        get {
            return backgroundImageView.image
        }
        set {
            backgroundImageView.image = newValue
        }
    }
    
    // MARK: Cells
    public func tableView(tableView: UITableView, cellForModule module: Module, andRow row: Int) -> UITableViewCell? {
        var cell: UITableViewCell? = nil
        switch module {
        case let textModule as TextModule:
            if let reusedCell = tableView.dequeueReusableCellWithIdentifier("Text") as? TextTableViewCell {
                
                let attributedText = NSMutableAttributedString(string: textModule.text)
               
                attributedText.addAttributes(textAttributesForModule(textModule), range: NSRange(location: 0, length: attributedText.length))
                
                reusedCell.titleTextView.attributedText = attributedText
                
                cell = reusedCell
            }
        case let imageModule as ImageModule:
            if let reusedCell = tableView.dequeueReusableCellWithIdentifier("Image") as? ImageTableViewCell {
                reusedCell.customImageView.image = imageModule.image
                
                cell = reusedCell
            }
        case let radioButtonsModule as RadioButtonsModule:
            let radioCell = UINib(nibName: "RadioTableViewCell", bundle: NSBundle(forClass: RadioTableViewCell.self)).instantiateWithOwner(nil, options: nil).first as! RadioTableViewCell
            
            radioCell.titleLabel.text = radioButtonsModule.options[row]
            radioCell.radioButtonSelected = (row == radioButtonsModule.selectedIndex)
            
            cell = radioCell
            
            // Reuse causes selection state to be reused
            /*
            if let reusedCell = tableView.dequeueReusableCellWithIdentifier("Radio") as? RadioTableViewCell {
                reusedCell.titleLabel.text = radioButtonsModule.options[row]
                
                reusedCell.radioButtonSelected = (row == radioButtonsModule.selectedIndex)
                
                cell = reusedCell
            }
            */
        case let checkboxesModule as CheckboxesModule:
            if let reusedCell = tableView.dequeueReusableCellWithIdentifier("Checkbox") as? CheckboxTableViewCell {
                reusedCell.titleLabel.text = checkboxesModule.options[row]
                
                reusedCell.checkboxButtonSelected = checkboxesModule.selectedIndices.contains(row)
                
                cell = reusedCell
            }
        case let listModule as ListModule:
            if let reusedCell = tableView.dequeueReusableCellWithIdentifier("Text") as? TextTableViewCell {
                let attributedText = NSMutableAttributedString(string: "\(row + 1)) \(listModule.options[row])")
                
                attributedText.addAttributes(textAttributesForModule(listModule), range: NSRange(location: 0, length: attributedText.length))
                
                reusedCell.titleTextView.attributedText = attributedText
                
                cell = reusedCell
            }
        default:
            break
        }
        
        cell?.backgroundColor = UIColor.clearColor()
        
        return cell
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
        guard let cell = self.tableView(tableView, cellForModule: node.modules[indexPath.section], andRow: indexPath.row) else {
            // Default cell
            let defaultCell: UITableViewCell
            if let reusedCell = tableView.dequeueReusableCellWithIdentifier("defaultCell") {
                defaultCell = reusedCell
            } else {
                defaultCell = UITableViewCell(style: .Default, reuseIdentifier: "defaultCell")
            }
            
            defaultCell.textLabel?.text = "Unknown"
            defaultCell.backgroundColor = UIColor.clearColor()
            
            return defaultCell
        }
        
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