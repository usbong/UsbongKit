//
//  TaskNodeType.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// Task node types
internal enum TaskNodeType: String {
    case TextDisplay = "textDisplay"
    case ImageDisplay = "imageDisplay"
    case TextImageDisplay = "textImageDisplay"
    case ImageTextDisplay = "imageTextDisplay"
    case Link = "link"
    case RadioButtons = "radioButtons"
    case Checklist = "checkList"
    case Classification = "classification"
    case TextField = "textField"
    case TextFieldNumerical = "textFieldNumerical"
    case TextFieldWithUnit = "textFieldWithUnit"
    case TextArea = "textArea"
    case TextFieldWithAnswer = "textFieldWithAnswer"
    case TextAreaWithAnswer = "textAreaWithAnswer"
    case TimestampDisplay = "timestampDisplay"
    case Date = "date"
    case RadioButtonsWithAnswer = "radioButtonsWithAnswer"
}
