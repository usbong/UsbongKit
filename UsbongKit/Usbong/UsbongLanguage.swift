//
//  UsbongLanguage.swift
//  UsbongKit
//
//  Created by Chris Amanse on 1/1/16.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// `UsbongLanguage` converts language string to language code
internal struct UsbongLanguage {
    internal init(language: String) {
        self.language = language
    }
    
    /// Language
    internal let language: String
    
    /// Get the language code based on the `language`. Default is "en-EN".
    internal var languageCode: String {
        switch language {
        case "English":
            return "en-EN"
        case "Czech":
            return "cs-CZ"
        case "Danish":
            return "da-DK"
        case "German":
            return "de-DE"
        case "Greek":
            return "el-GR"
        case "Spanish", "Bisaya", "Ilonggo", "Tagalog", "Filipino":
            return "es-ES"
        case "Finnish":
            return "fi-FI"
        case "French":
            return "fr-FR"
        case "Hindi":
            return "hi-IN"
        case "Hungarian":
            return "hu-HU"
        case "Indonesian":
            return "id-ID"
        case "Italian":
            return "it-IT"
        case "Japanese":
            return "ja-JP"
        case "Korean":
            return "ko-KR"
        case "Dutch":
            return "nl-BE"
        case "Norwegian":
            return "nb-NO"
        case "Polish":
            return "pl-PL"
        case "Portuguese":
            return "pt-PT"
        case "Romanian":
            return "ro-RO"
        case "Russian":
            return "ru-RU"
        case "Slovak":
            return "sk-SK"
        case "Swedish":
            return "sv-SE"
        case "Thai":
            return "th-TH"
        case "Turkish":
            return "tr-TR"
        case "Chinese":
            return "zh-CN"
        default:
            return "en-EN"
        }
    }
}