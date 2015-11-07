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
import Crypto
import ZipArchive

public class UsbongFileManager {
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
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1].URLByAppendingPathComponent("trees", isDirectory: true)
    }()
    
    public var defaultFileName = "Unnamed"
    
    public func contentsOfDirectoryAtRootURL() -> [NSURL]? {
        return try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(rootURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
    }
    
    public func clearCacheDirectory() -> Bool {
        return (try? NSFileManager.defaultManager().removeItemAtURL(cacheDirectoryURL)) != nil
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
        
        // Return first .utree found, else, return nil
        return contents?.filter({ $0.pathExtension == "utree" }).first ?? nil
    }
    
    public func unpackTreeWithURL(url: NSURL, toDestinationURL destinationURL: NSURL) -> NSURL? {
        // Make sure tree URL is a file and destination url is a directory, else, return nil
//        if #available(iOS 9.0, *) {
//            guard !url.hasDirectoryPath && destinationURL.hasDirectoryPath else {
//                print("UsbongFileManager: Invalid URLs\nurl: \(url) \(url.fileURL)\ndestinationURL: \(destinationURL) \(destinationURL.fileURL)")
//                return nil
//            }
//        } else {
            // Fallback on earlier versions
//            print(url.path?.characters.last)
//            print(destinationURL.path?.characters.last)
//            guard url.path?[(url.path?.endIndex.predecessor())!] != "/" && destinationURL.path?[(destinationURL.path?.endIndex.predecessor())!] == "/" else {
//                print("UsbongFileManager: Invalid URLs\nurl: \(url) \ndestinationURL: \(destinationURL)")
//                return nil
//            }
//        }
        
        // Unpack
        if let zipPath = url.path, let destinationPath = destinationURL.path {
            guard Main.unzipFileAtPath(zipPath, toDestination: destinationPath) else {
                print("Failed to unzip")
                return nil
            }
            
            // Return first tree in unpacked directory
            return firstTreeInURL(destinationURL)
        }
        
        // If paths are nil, return nil
        print("UsbongFileManager: Paths are nil")
        return nil
    }
    
    public func unpackTreeToTemporaryDirectoryWithTreeURL(treeURL: NSURL) -> NSURL? {
        let md5Data = (NSData(contentsOfURL: treeURL) ?? NSData(bytes: nil, length: 64)).MD5
        
        // Convert md5Data to string
        let buf = UnsafePointer<UInt8>(md5Data.bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(i: UInt8) -> UInt8 {
            return (i > 9) ? (charA + i - 10) : (char0 + i)
        }
        
        let dataLength = md5Data.length
        let p = UnsafeMutablePointer<UInt8>.alloc(dataLength * 2)
        
        for i in 0..<dataLength {
            p[i*2] = itoh((buf[i] >> 4) & 0xF)
            p[i*2+1] = itoh(buf[i] & 0xF)
        }
        
        let md5 = NSString(bytesNoCopy: p, length: dataLength*2, encoding: NSUTF8StringEncoding, freeWhenDone: true) as! String
        
        // Create Unpack directory URL
        let unpackDirectoryURL = cacheDirectoryURL.URLByAppendingPathComponent("\(md5)", isDirectory: true)
        
        // TODO: If temporary directory has lots of unpacked trees, delete all first
        
        // If unpack directory exists, it means, same file is already unpacked
        if NSFileManager.defaultManager().fileExistsAtPath(unpackDirectoryURL.path ?? "") {
            print("UsbongFileManager: Tree has already been unpacked before. Skipping unpack...")
            
            // Return first tree in unpacked directory
            return firstTreeInURL(unpackDirectoryURL)
        }
        print(unpackDirectoryURL.path)
        
        return unpackTreeWithURL(treeURL, toDestinationURL: unpackDirectoryURL)
    }
}