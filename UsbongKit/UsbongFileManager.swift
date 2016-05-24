//
//  UsbongFileManager.swift
//  usbong
//
//  Created by Chris Amanse on 21/09/2015.
//  Copyright 2015 Usbong Social Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import ZipArchive

public class UsbongFileManager {
    private init() {} // Make sure it can't be initialized
    
    private static var _defaultManager = UsbongFileManager()
    public static func defaultManager() -> UsbongFileManager {
        return UsbongFileManager._defaultManager
    }
    
    public var rootURL: NSURL = {
        // Default root URL is App's Documents folder
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    public var cacheDirectoryURL: NSURL = {
        // Default cache directory is ./Library/Caches/trees/
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1].URLByAppendingPathComponent("trees", isDirectory: true)
    }()
    
    public var defaultFileName = "Untitled"
    
    public func contentsOfDirectoryAtRootURL() -> [NSURL]? {
        return try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(rootURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
    }
    
    public func clearCacheDirectory() -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(cacheDirectoryURL)
            return true
        } catch {
            return false
        }
    }
    
    public func treesAtRootURL() -> [NSURL] {
        if let contents = contentsOfDirectoryAtRootURL() {
            // filter contents to URLs with path extension 'utree'
            return contents.filter({ $0.pathExtension == "utree" })
        }
        
        // Return empty array if contents is nil
        return []
    }
    
    public func firstTreeInURL(url: NSURL) -> NSURL? {
        // Get directory of .utree folder in unpack directory
        let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        
        // Return first *.utree directory found, else, return nil
        return contents?.filter({ $0.pathExtension == "utree" }).first ?? nil
    }
    
    public func unpackTreeWithURL(url: NSURL, toDestinationURL destinationURL: NSURL) -> NSURL? {
        // Unpack
        guard let zipPath = url.path, let destinationPath = destinationURL.path else {
            // If paths are nil, return nil
            print("UsbongFileManager: Paths are nil")
            return nil
        }
        
        // Attempt to unzip
        guard Main.unzipFileAtPath(zipPath, toDestination: destinationPath) else {
            print("UsbongFileManager: Failed to unzip")
            return nil
        }
        
        // Return first tree in unpacked directory
        return firstTreeInURL(destinationURL)
    }
    
    public func unpackTreeToCacheDirectoryWithTreeURL(treeURL: NSURL) -> NSURL? {
        // Generate unique string to ensure unpack to new clean directory
        let uniqueId = NSUUID().UUIDString
        
        // Create Unpack directory URL
        let unpackDirectoryURL = cacheDirectoryURL.URLByAppendingPathComponent("\(uniqueId)", isDirectory: true)
        
        // TODO: If temporary directory has lots of unpacked trees, delete all first
        
        // If unpack directory exists, it means, same file is already unpacked
        if NSFileManager.defaultManager().fileExistsAtPath(unpackDirectoryURL.path ?? "") {
            print("UsbongFileManager: Tree has already been unpacked before. Skipping unpack...")
            
            // Return first tree in unpacked directory
            return firstTreeInURL(unpackDirectoryURL)
        }
        print("UsbongFileManager:\nUnpack directory URL: \(unpackDirectoryURL.path)")
        
        return unpackTreeWithURL(treeURL, toDestinationURL: unpackDirectoryURL)
    }
}