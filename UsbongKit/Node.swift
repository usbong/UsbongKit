import UIKit

// MARK: - Nodes

//  - Nodes are collections of modules that provide convenient creation of common module coombinations
//  - order of modules matter
public class Node {
    public let modules: [Module]
    
    public init(modules: [Module]) {
        self.modules = modules
    }
}

// MARK: - SelectionTypeNode
//   - node that supports selection
public protocol SelectionTypeNode {
    var selectionModule: SelectionTypeModule { get }
}

// MARK: - textDisplay
public class TextNode: Node {
    public init(text: String) {
        super.init(modules: [TextModule(text: text)])
    }
}

// MARK: - imageDisplay
public class ImageNode: Node {
    public init(image: UIImage?) {
        super.init(modules: [ImageModule(image: image)])
    }
}

// MARK: - textImageDisplay
//   - displays a text, then image below
public class TextImageNode: Node {
    public init(text: String, image: UIImage?) {
        super.init(modules: [
            TextModule(text: text),
            ImageModule(image: image)
            ])
    }
}

// MARK: - imageTextDisplay
//   - displays an image, then text below
public class ImageTextNode: Node {
    public init(image: UIImage?, text: String) {
        super.init(modules: [
            ImageModule(image: image),
            TextModule(text: text)
            ])
    }
}

// MARK: - classification 
//   - numbered list
public class ClassificationNode: Node {
    public init(text: String, list: [String]) {
        super.init(modules: [
            TextModule(text: text),
            ListModule(options: list)
            ])
    }
}

// MARK: - checkList
public class ChecklistNode: Node {
    public init(text: String, options: [String], selectedIndices: [Int] = []) {
        super.init(modules: [
            TextModule(text: text),
            CheckboxesModule(options: options, selectedIndices: selectedIndices)
            ])
    }
}

extension ChecklistNode: SelectionTypeNode {
    public var selectionModule: SelectionTypeModule {
        return modules[1] as! SelectionTypeModule
    }
}

// MARK: - radioButtons
// MARK: link
//   - options will link to other nodes
// MARK: decision
//   - similar to link but with yes or no options only
// view sees it all as the same things, only node generator/provider will know what's what
public class RadioButtonsNode: Node {
    public init(text: String, options: [String], selectedIndex: Int? = nil) {
        super.init(modules: [
            TextModule(text: text),
            RadioButtonsModule(options: options, selectedIndex: selectedIndex)
            ])
    }
}

extension RadioButtonsNode: SelectionTypeNode {
    public var selectionModule: SelectionTypeModule {
        return modules[1] as! SelectionTypeModule
    }
}

public protocol TextInputTypeNode: class {
    var textInput: String { get set }
}

public class TextFieldNode: Node, TextInputTypeNode {
    public init(text: String, textInput: String = "") {
        super.init(modules: [
            TextModule(text: text),
            TextInputModule(textInput: textInput)
            ])
    }
    
    public var textInput: String {
        get {
            return (modules[1] as! TextInputModule).textInput
        }
        set {
            (modules[1] as! TextInputModule).textInput = newValue
        }
    }
}

public class TextFieldNumericalNode: Node, TextInputTypeNode {
    public init(text: String, textInput: String = "") {
        super.init(modules: [
            TextModule(text: text),
            TextInputModule(textInput: textInput, type: .SingleLineNumerical)
            ])
    }
    
    public var textInput: String {
        get {
            return (modules[1] as! TextInputModule).textInput
        }
        set {
            (modules[1] as! TextInputModule).textInput = newValue
        }
    }
}

public class TextFieldWithUnitNode: Node, TextInputTypeNode {
    public init(text: String, textInput: String = "", unit: String) {
        super.init(modules: [
            TextModule(text: text),
            TextInputModule(textInput: textInput, type: .SingleLineNumerical),
            TextModule(text: unit)
            ])
    }
    
    public var textInput: String {
        get {
            return (modules[1] as! TextInputModule).textInput
        }
        set {
            (modules[1] as! TextInputModule).textInput = newValue
        }
    }
}

public class TextAreaNode: Node, TextInputTypeNode {
    public init(text: String, textInput: String = "") {
        super.init(modules: [
            TextModule(text: text),
            TextInputModule(textInput: textInput, type: .MultipleLine)
            ])
    }
    
    public var textInput: String {
        get {
            return (modules[1] as! TextInputModule).textInput
        }
        set {
            (modules[1] as! TextInputModule).textInput = newValue
        }
    }
}
