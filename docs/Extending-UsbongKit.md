# Extending UsbongKit

This is the documentation for extending UsbongKit, such as adding Nodes, Modules, and Task Nodes.

# Adding Modules

To add modules, simply create a class and conform it to the `Module` protocol. The current modules are located in `UsbongKit/Modules/` directory, thus, it is best to add new modules in this directory.

Let's say you want to create a title module, a module that displays text with a header style:

- Create `TitleModule.swift` with contents:

```swift

public class VideoModule: Module {
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

- That's it! You've created your own module. To display it, you need to add you module to a node. To have a specific combination of modules in a node, you can create a new `Node` subclass.

# Adding Nodes

# Adding Task Nodes
