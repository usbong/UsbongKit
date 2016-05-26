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
import Zip

/// File manager that manages utree files
public class UsbongFileManager {
    /// Only one instance of `UsbongFileManager` is allowed
    private init() {
        // Set custom file extension for Zip
        Zip.addCustomFileExtension("utree")
    }
    
    /// Property for storing the default `UsbongFileManager`
    private static var _defaultManager = UsbongFileManager()
    
    /// Get the default `UsbongFileManager`
    public static func defaultManager() -> UsbongFileManager {
        return UsbongFileManager._defaultManager
    }
    
    /// The root URL where `UsbongFileManager` will search for utree files
    public var rootURL: NSURL = {
        // Default root URL is App's Documents folder
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    /// The cache URL where utrees will be unzipped
    public var cacheDirectoryURL: NSURL = {
        // Default cache directory is ./Library/Caches/trees/
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1].URLByAppendingPathComponent("trees", isDirectory: true)
    }()
    
    /// Default filename for utree files
    public var defaultFileName = "Untitled"
    
    /// Get the contents of `rootURL`
    public func contentsOfDirectoryAtRootURL() -> [NSURL]? {
        return try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(rootURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
    }
    
    /// Clears the cache directory
    public func clearCacheDirectory() -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(cacheDirectoryURL)
            return true
        } catch {
            return false
        }
    }
    
    /// Get the utree files inside `rootURL`
    public func treesAtRootURL() -> [NSURL] {
        if let contents = contentsOfDirectoryAtRootURL() {
            // filter contents to URLs with path extension 'utree'
            return contents.filter { $0.pathExtension == "utree" }
        }
        
        // Return empty array if contents is nil
        return []
    }
    
    /**
     Get the first found folder with .utree extension. This is typically used for the unpacked .utree.
     
     - parameter url: URL of unpacked .utree
     
     - returns: URL of folder with .utree extension
    */
    public func firstTreeInURL(url: NSURL) -> NSURL? {
        // Get directory of .utree folder in unpack directory
        let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        
        // Return first *.utree directory found, else, return nil
        return contents?.filter({ $0.pathExtension == "utree" }).first ?? nil
    }
    
    /**
     Unpack a utree file at `url` to `destinationURL`
     
     - parameters:
       - url: URL of compressed .utree
       - destinationURL: Target location where the unpacked contents of the .utree will be placed
     
     - returns: URL of folder with .utree extension
    */
    public func unpackTreeWithURL(url: NSURL, toDestinationURL destinationURL: NSURL) -> NSURL? {
        // Attempt to unzip
        do {
            try Zip.unzipFile(url, destination: destinationURL, overwrite: true, password: nil, progress: nil)
            
            // Return first tree in unpacked directory
            return firstTreeInURL(destinationURL)
        } catch let error {
            print("[UsbongKit, Zip] Failed to unzip: \(error)")
            return nil
        }
    }
    
    /**
     Unpack a utree file to default directory in cache. Cache directory is determined by `cacheDirectoryURL`.
     
     - parameter treeURL: URL of compressed .utree
     
     - returns: URL of folder with .utree extension
    */
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