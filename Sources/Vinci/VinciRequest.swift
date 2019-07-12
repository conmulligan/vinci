//
//  VinciRequest.swift
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
import UIKit

/// Fetches and modifies an image from a remote URL.
open class VinciRequest {
    
    /// The completion handler.
    public typealias CompletionHandler = ((_ image: UIImage?, _ isCached: Bool) -> Void)
    
    /// The `Vinci` context.
    private var vinci: Vinci
    
    /// The operation associated with this request.
    private var operation: VinciRequestOperation?
    
    // MARK: - Initialization
    
    /// Initializes the request with the supplied `Vinci` instance.
    ///
    /// - parameter vinci: The `Vinci` context.
    required public init(vinci: Vinci) {
        self.vinci = vinci
    }

    // MARK: - Request
    
    /// Fetches an image from a remote URL.
    ///
    /// - Parameters:
    ///   - url: The URL of an image to fetch.
    ///   - completionHandler: A completion handler which is called when the request finishes.
    public func get(url: URL, completionHandler: @escaping CompletionHandler) {
        self.get(url: url, modifiers: nil, completionHandler: completionHandler)
    }

    /// Fetches and modifies an image from a remote URL.
    ///
    /// - Parameters:
    ///   - url: The URL of an image to fetch.
    ///   - modifiers: The modifiers to apply.
    ///   - completionHandler: A completion handler which is called when the request finishes.
    public func get(url: URL, modifiers: [Modifier]?, completionHandler: @escaping CompletionHandler) {
        
        // Check if a memory cached version of the image exists.
        if let image = self.cachedImage(for: url, modifiers: modifiers, memoryOnly: true) {
            if Vinci.debugMode {
                os_log("Returning memory cached modified image for %@.", type: .debug, url.path)
            }
            
            completionHandler(image, true)
            return
        }

        // Check the disk cache on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Check if a memory cached version of the image exists.
            if let image = self.cachedImage(for: url, modifiers: modifiers, memoryOnly: false) {
                if Vinci.debugMode {
                    os_log("Returning disk cached modified image for %@.", type: .debug, url.path)
                }
                
                // Return the image on the main thread.
                DispatchQueue.main.async {
                    completionHandler(image, true)
                }
                return
            }

            // Otherwise, create a data task to fetch the image.
            self.operation = VinciRequestOperation(session: self.vinci.session, url: url) { (image, response, error) in
                
                // If the image is nil, call the completion handler and bail out.
                guard var image = image else {
                    DispatchQueue.main.async {
                        completionHandler(nil, false)
                    }
                    return
                }
                
                // Cache the unmodified image.
                self.vinci.cache.setObject(image, forKey: url)
                
                // If any modifiers have been set, cache the modified image.
                if let modifiers = modifiers, modifiers.count > 0 {
                    image = self.modify(image: image, modifiers: modifiers)
                    
                    self.vinci.cache.setObject(image, forKey: self.vinci.keyFor(url: url, modifiers: modifiers))
                }
                
                // Return the image on the main thread.
                DispatchQueue.main.async {
                    completionHandler(image, false)
                }
            }
            
            // Queue the request operation.
            self.vinci.addOperation(self.operation!)
        }
    }

    /// Cancels the request operation.
    public func cancel() {
        operation?.cancel()
    }
    
    private func cachedImage(for url: URL, modifiers: [Modifier]?, memoryOnly: Bool) -> UIImage? {
        var image: UIImage? = nil
        
        // If any modifiers have been set, check if a check version of the image exists.
        if let modifiers = modifiers, modifiers.count > 0 {
            if memoryOnly {
                image = self.vinci.cache.objectFromMemory(forKey: self.vinci.keyFor(url: url, modifiers: modifiers))
            } else {
                image = self.vinci.cache.object(forKey: self.vinci.keyFor(url: url, modifiers: modifiers))
            }
        }
        
        // Check if an in-memory cached version of the image exists.
        if image == nil {
            if memoryOnly {
                image = self.vinci.cache.objectFromMemory(forKey: url)
            } else {
                image = self.vinci.cache.object(forKey: url)
            }
            
            if image != nil {
                // If any modifiers have been set, cache the modified image.
                if let modifiers = modifiers, modifiers.count > 0 {
                    image = self.modify(image: image!, modifiers: modifiers)
                    
                    self.vinci.cache.setObject(image!, forKey: self.vinci.keyFor(url: url, modifiers: modifiers))
                }
            }
        }
        
        return image
    }
    
    /// Executes all the supplied modifiers and returns the modified image.
    ///
    /// - Parameters:
    ///   - image: The image to modify.
    ///   - modifiers: An array of `Modifier` instances.
    /// - Returns: The modified image.
    private func modify(image: UIImage, modifiers: [Modifier]?) -> UIImage {
        var img = image
        if let modifiers = modifiers {
            for modifier in modifiers {
                img = modifier.modify(image: img)
            }
        }
        return img
    }
}
