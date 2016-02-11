import UIKit

// MARK: - Module
// Dummy protocol where all modules should conform too
public protocol Module {}

// MARK: - OptionsTypeModule
// Protocol for list type
public protocol OptionsTypeModule: Module {
    var options: [String] { get set }
}

// MARK: - SelectionTypeModule
// Protocol for selection type
public protocol SelectionTypeModule: Module {
    var selectedIndices: [Int] { get }
    func selectIndex(index: Int)
    func deselectIndex(index: Int)
    func toggleIndex(index: Int)
}

// MARK: - Text
public class TextModule: Module {
    public var text: String = ""
    
    public init(text: String) {
        self.text = text
    }
}

// MARK: - Image
public class ImageModule: Module {
    public var image: UIImage? = nil
    
    public init(image: UIImage?) {
        self.image = image
    }
}

// MARK: - List
public class ListModule: OptionsTypeModule {
    public var options: [String] = []
    
    public init(options: [String]) {
        self.options = options
    }
}

// MARK: - Radio buttons
public class RadioButtonsModule: ListModule, SelectionTypeModule {
    public var selectedIndex: Int? = nil
    
    public init(options: [String], selectedIndex: Int? = nil) {
        super.init(options: options)
        self.selectedIndex = selectedIndex
    }
    
    // MARK: Selection type module
    public var selectedIndices: [Int] {
        if let index = selectedIndex {
            return [index]
        }
        return []
    }
    
    public func selectIndex(index: Int) {
        selectedIndex = index
    }
    public func deselectIndex(index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        }
    }
    public func toggleIndex(index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
    }
}

// MARK: - Checkboxes
public class CheckboxesModule: ListModule, SelectionTypeModule {
    public init(options: [String], selectedIndices: [Int] = []) {
        super.init(options: options)
        self.selectedIndices = selectedIndices
    }
    
    // MARK: Selection type module
    public private(set) var selectedIndices: [Int] = []
    
    public func selectIndex(index: Int) {
        if !selectedIndices.contains(index) {
            selectedIndices.append(index)
        }
    }
    public func deselectIndex(index: Int) {
        while let indexOfIndex = selectedIndices.indexOf(index) {
            selectedIndices.removeAtIndex(indexOfIndex)
        }
    }
    public func toggleIndex(index: Int) {
        if selectedIndices.contains(index) {
            deselectIndex(index)
        } else {
            selectedIndices.append(index)
        }
    }
}

// MARK: - TextInputModule
public class TextInputModule: Module {
    public var textInput: String
    public var multipleLine: Bool // true: TextArea
    
    /// Create `TextInputModule` with specified `mulitpleLine`
    public init(textInput: String = "", multipleLine: Bool) {
        self.textInput = textInput
        self.multipleLine = multipleLine
    }
    
    /// Create single line `TextInputModule`
    public convenience init(textInput: String = "") {
        self.init(textInput: textInput, multipleLine: false)
    }
}
