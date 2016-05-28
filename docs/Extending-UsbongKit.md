# Extending UsbongKit

This is the documentation for extending UsbongKit, such as adding Nodes, Modules, and Task Nodes.

# Adding Modules

To add modules, simply create a class and conform it to the `Module` protocol. The current modules are located in `UsbongKit/Modules/` directory, thus, it is best to add new modules in this directory.

Let's say you want to create a title module, a module that displays text with a header style:

- Create `TitleModule.swift` with contents:

```swift

public class TitleModule: Module {
  public var title: String

  public init(title: String) {
    self.title = title
  }
}

```

- Now that you have the module, it's time to create a view for it. All views for the modules are subclasses of `UITableViewCell`s, since they are rendered inside a `UITableView`. The views are located in `UsbongKit/Views/`. Create the cell subclass, `TitleTableViewCell`, and customize it to your needs. If you create a nib (`.xib` file), it's best to conform your `UITableViewCell` subclass to `NibReusable`. If you're not using a nib, conform instead to `Reusable`. It will be used later in the `NodeView` for registering your cell in the `UITableView`. For example:

```swift

public class TitleTableViewCell: UITableViewCell, NibReusable {
  @IBOutlet public weak var titleLabel: UILabel!
}

```

- Now that you have the module and its view, you can now add code in `NodeView` to display the module. `NodeView` is located in `UsbongKit/Nodes/NodeView.swift`. First, register your cell subclass to the table view in the `sharedInitialization()` function (registering the cell will allow you to use it in the `UITableView`):

```swift

tableView.registerReusableCell(TitleTableViewCell)

```

- You can now add code to display the cell for that module. Find the function `public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell`. It is located in `extension NodeView: UITableViewDataSource`. You can see there that there is a switch statement, and the cases are for determining what type of module is the current module for that row. Go ahead and add a case for your `TitleModule`:

```swift

case let titleModule as TitleModule:
  let reusedCell = tableView.dequeReusableCell(indexPath: indexPath) as TitleTableViewCell

  // Change the title in the view/cell
  reusedCell.titleLabel.text = titleModule.title

  // Pass the reusedCell to the cell variable, which is the one to be rendered
  cell = reusedCell

```

- That's it! You've created your own module. To display it, you need to add your module to a node. You can look at the example app in `UsbongKit-example/`, to display your node with your module. `UsbongKit-example/NodesTableViewController` shows a list of nodes to be displayed. You can add a node with your module in the `nodes: [Node]` array (ex. `Node(modules: [TitleModule(title: "A Title Module")])`). To have a specific combination of modules in a node, you can create a new `Node` subclass.

# Adding Nodes

Creating a Node is faster than creating a module since a Node is simply a collection of modules. Thus, to create a custom node, subclass `Node`, and add in your combination of modules in `modules`. Let's say you want to create a Node with your `TitleModule` and the node you want is a combination of a title followed by a text (`TextModule`):

```swift

public class TitleAndTextNode: Node {
  public init(title: String, text: String) {
    super.init(modules: [
      TitleModule(title: title),
      TextModule(text: text)
      ])
  }
}

```

You can also add this node to the UsbongKit example app mentioned earlier.

# Adding Task Nodes

Assuming you've created your custom node and its view for your new task node, you can add a new one in `UsbongTree`, which is a class for parsing the utree format.

- To add a task node, the first thing you need to do is add a case in the enum `TaskNodeType`, and its corresponding string (determined by the type in the task-node name). Let's say you added a `titleTextDisplay`, which corresponds to your `TitleAndTextNode`:

```swift

case TitleTextDisplay = "titleTextDisplay"

```

- You'll notice that there is an error. It's located in the switch statement of the function `nodeWithName(taskNodeName: String) -> Node` in the class `UsbongTree`. It's found in `UsbongKit/Usbong/UsbongTree/UsbongTree.swift`. The switch statement now has an error because it doesn't handle all the cases in the `TaskNodeType` enum since you've added a new case, `TitleAndTextDisplay`.
  - First let's learn what this function does. In this function, it fetches the task node in the XML with the name inside the `taskNodeName` variable.
    - You can see a `nameInfo` variable, an `XMLNameInfo` object, inside the function. This name info simply decomposes the task-node name into components and provides properties for easier access to images, audios and text determined by the utree format. The `nameInfo.text` is the text of the node which is always the last component in the task node name. The `nameInfo.type` is the task node type (such as textDisplay, imageDisplay, etc.).
    - The `nodeIndexerAndTypeWithName(taskNodeName)` returns multiple values (called a tuple). The first value is the XML tag, while the second value is the `NodeType`, a main type of a task node. There are three main types of a task node: `TaskNode`, `Decision`, and `EndState`. These are determined by the XML tag of the utree format.
    - The `finalText` variable is a translated and parsed text of the task node.
- Since the type of the task node is in `nameInfo.type`, we create a switch statement for it to apply custom behavior for each task node type. Thus, we add our case there for our `TitleTextDisplay`:

```swift

case .TitleTextDisplay:
  // Let's assume the title is located in the 2nd component of the task node name
  // You can also customize XMLNameInfo to add a property for title
  let title = nameInfo.components[1]

  // Create the TitleAndTextNode and pass it to the node variable
  node = TitleAndTextNode(title: title, text: finalText)

```

- You've now added a new task node! You can test it by creating a utree with your new task node.
