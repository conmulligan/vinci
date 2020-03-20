//
//  VinciCache.swift
//  Vinci
//
//  Created by Conor Mulligan on 01/04/2018.
//  Copyright © 2018 Conor Mulligan.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import os.log
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// A combined memory and disk cache for downloaded images.
open class VinciCache {
    /// The directory in which cached images are stored.
    private static let cacheDirectory = "Images"

    /// The internal in-memory cache.
    private let memCache = NSCache<AnyObject, AnyObject>()

    /// The application cache directory.
    var directory: URL {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = urls[urls.count - 1]
        return directory.appendingPathComponent(VinciCache.cacheDirectory)
    }

    // MARK: - Initialization

    public init() {

    }
    
    // MARK: - Caching

    /// Queries the caches for an image matching for the supplied URL.
    ///
    /// - parameter key: A `URL` value acting as a key.
    /// - returns: A `UIImage` instance if one exists; otherwise, nil.
    public func object(forKey key: URL) -> UIImage? {
        
        // First, check the in-memory cache.
        var image = self.objectFromMemory(forKey: key)
        
        // If the in-memory cache doesn't have a copy of the image, check the disk cache.
        if image == nil {
            image = self.objectFromDisk(forKey: key)
        }
        
        return image
    }

    /// Queries the memory cache for an image matching for the supplied URL.
    ///
    /// - parameter key: A `URL` value acting as a key.
    /// - returns: A `UIImage` instance if one exists; otherwise, nil.
    public func objectFromMemory(forKey key: URL) -> UIImage? {
        return self.memCache.object(forKey: key as NSURL) as? UIImage
    }
    
    /// Queries the disk cache for an image matching for the supplied URL.
    ///
    /// - parameter key: A `URL` value acting as a key.
    /// - returns: A `UIImage` instance if one exists; otherwise, nil.
    public func objectFromDisk(forKey key: URL) -> UIImage? {
        var image: UIImage?
        let filename = key.path.MD5
        let url = directory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: url.path) {
            if Vinci.debugMode {
                os_log("Cached file exists at %@.", type: .debug, url.path)
            }
            
            image = UIImage(contentsOfFile: url.path)
            
            // After fetching an image from the disk, save it to the in-memory cache.
            if let image = image {
                self.memCache.setObject(image, forKey: key as NSURL)
            }
        }
        
        return image
    }
    
    /// Saves the supplied image to both the memory and disk cache.
    /// The URL value is used as a key.
    ///
    /// - Parameters:
    ///   - object: The `UIImage` instance to cache.
    ///   - key: The `URL` value acting as a key.
    func setObject(_ obj: UIImage, forKey key: URL) {
        // First, save the image in the in-memory cache.
        self.memCache.setObject(obj, forKey: key as NSURL)

        // Second, persist the image to disk.
        let filename = key.path.MD5
        let manager = FileManager.default
        let url = self.directory.appendingPathComponent(filename)

        let data: Data!

        if self.isJPG(filename) {
            data = obj.jpegData(compressionQuality: 1)
        } else if self.isPNG(filename) {
            data = obj.pngData()
        } else {
            data = obj.pngData()
        }
        
        // Create the directory if it doesn't exist.
        if !manager.fileExists(atPath: directory.path) {
            do {
                try manager.createDirectory(atPath: directory.path,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            } catch {
                os_log("Error creating directory at %@; error: %@", type: .error, url.path, error.localizedDescription)
            }
        }

        // If a file with the same path already exists, delete it.
        if manager.fileExists(atPath: url.path) {
            do {
                try manager.removeItem(atPath: url.path)
            } catch {
                os_log("Error removing item at %@; error: %@", type: .error, url.path, error.localizedDescription)
            }
        }

        // Write the file to disk.
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            os_log("Error creating item at %@; error: %@", type: .error, url.path, error.localizedDescription)
        }
    }
}

/// Extends the `VinciCache` class with functions related to file type support.
extension VinciCache {
    
    /// Supported image file type extensions.
    private enum FileType {
        static let PNG = "png"
        static let JPG = "jpg"
        static let JPEG = "jpeg"
    }
    
    /// Checks if a filename has the .png extension.
    ///
    /// - parameter filename: The filename to check.
    /// - returns: True if the filename contains the .png extension; otherwise, false.
    private func isPNG(_ filename: String) -> Bool {
        return filename.lowercased().hasSuffix(FileType.PNG)
    }
    
    /// Checks if a filename has the .jpg or .jpeg extension.
    ///
    /// - parameter filename: The filename to check.
    /// - returns: True if the filename contains the .jpg or .jpeg extensions; otherwise, false.
    private func isJPG(_ filename: String) -> Bool {
        return filename.lowercased().hasSuffix(FileType.JPG) || filename.lowercased().hasSuffix(FileType.JPEG)
    }
}
