# UsbongKit
[![License](https://img.shields.io/badge/license-ALv2-blue.svg)](./LICENSE)
[![GitHub Release](https://img.shields.io/github/release/usbong/usbongkit.svg)](https://github.com/usbong/UsbongKit/releases)

UsbongKit is a framework that contains the main components for Usbong.

# To-do

- [x] Add documentation
- [ ] CocoaPods support

# Running the Example App

- Make sure you have [carthage](https://github.com/Carthage/Carthage) installed
- Run `carthage update` in the project
- Build and run the `UsbongKit-example` target

# Installation

You can integrate `UsbongKit` in your project in different ways:

## Sub-Project

1. Drag-and-drop `UsbongKit.xcodeproj` as sub-project
2. Run `carthage update --platform iOS` in UsbongKit folder to fetch dependencies
3. Link `UsbongKit.framework` in your project

## Embed Framework

1. Run `carthage update --platform iOS` in UsbongKit folder to fetch dependencies
2. Build `UsbongKit` framework
3. Embed `UsbongKit.framework` in your project

## [Carthage](https://github.com/carthage/carthage)

1. Add `github "usbong/UsbongKit"` in your `Cartfile`
2. Run `carthage update --platform iOS` in your project directory
3. Follow [Carthage](https://github.com/carthage/carthage) instructions to add frameworks in your project

# View utree

To view a utree file, import the framework, `import UsbongKit`, then add this code in your app:

```swift

// parentViewController is the controller which will present the Usbong tree viewer
// treeURL is the URL for the compressed .utree
Usbong.presentViewer(onViewController: parentViewController, withUtreeURL: treeURL)

```

# Extend UsbongKit

The documentation for extending UsbongKit can be found [here](./docs/Extending-UsbongKit.md).

# License

   Copyright 2016 Usbong Social Systems, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
