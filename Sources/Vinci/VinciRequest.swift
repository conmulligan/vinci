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

/// Fetches and transforms an image from a remote URL.
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
        self.get(url: url, transformers: nil, completionHandler: completionHandler)
    }

    /// Fetches and transforms an image from a remote URL.
    ///
    /// - Parameters:
    ///   - url: The URL of an image to fetch.
    ///   - transformHandler: A transform handler responsible for transforming and return the supplied image.
    ///   - completionHandler: A completion handler which is called when the request finishes.
    public func get(url: URL, transformers: [Transformer]?, completionHandler: @escaping CompletionHandler) {
        
        // Check if a memory cached version of the image exists.
        if let image = self.cachedImage(for: url, transformers: transformers, memoryOnly: true) {
            if Vinci.debugMode {
                os_log("Returning memory cached transformed image for %@.", type: .debug, url.path)
            }
            
            completionHandler(image, true)
            return
        }

        // Check the disk cache on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Check if a memory cached version of the image exists.
            if let image = self.cachedImage(for: url, transformers: transformers, memoryOnly: false) {
                if Vinci.debugMode {
                    os_log("Returning disk cached transformed image for %@.", type: .debug, url.path)
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
                
                // If any transformers have been set, cache the transformed image.
                if let transformers = transformers, transformers.count > 0 {
                    image = self.doTransforms(image: image, transformers: transformers)
                    
                    self.vinci.cache.setObject(image, forKey: self.vinci.keyFor(url: url, transformers: transformers))
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
    
    private func cachedImage(for url: URL, transformers: [Transformer]?, memoryOnly: Bool) -> UIImage? {
        var image: UIImage? = nil
        
        // If any transformers have been set, check if a check version of the image exists.
        if let transformers = transformers, transformers.count > 0 {
            if memoryOnly {
                image = self.vinci.cache.objectFromMemory(forKey: self.vinci.keyFor(url: url, transformers: transformers))
            } else {
                image = self.vinci.cache.object(forKey: self.vinci.keyFor(url: url, transformers: transformers))
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
                // If any transformers have been set, cache the transformed image.
                if let transformers = transformers, transformers.count > 0 {
                    image = self.doTransforms(image: image!, transformers: transformers)
                    
                    self.vinci.cache.setObject(image!, forKey: self.vinci.keyFor(url: url, transformers: transformers))
                }
            }
        }
        
        return image
    }
    
    /// Executes all the supplied transformers and returns the modified image.
    ///
    /// - Parameters:
    ///   - image: The image to transform.
    ///   - transformers: An array of `Transformer` instances.
    /// - Returns: The transformed image.
    private func doTransforms(image: UIImage, transformers: [Transformer]?) -> UIImage {
        var img = image
        if let transformers = transformers {
            for transformer in transformers {
                img = transformer.doTransform(image: img)
            }
        }
        return img
    }
}
