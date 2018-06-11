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
    
    /// The transform handler.
    public typealias TransformHandler = ((_ image: UIImage) -> UIImage)
    
    /// The completion handler.
    public typealias CompletionHandler = ((_ image: UIImage?, _ isCached: Bool) -> Void)
    
    /// The `Vinci` context.
    private var vinci: Vinci!
    
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
        self.get(url: url, transformHandler: nil, completionHandler: completionHandler)
    }

    /// Fetches and transforms an image from a remote URL.
    ///
    /// - Parameters:
    ///   - url: The URL of an image to fetch.
    ///   - transformHandler: A transform handler responsible for transforming and return the supplied image.
    ///   - completionHandler: A completion handler which is called when the request finishes.
    public func get(url: URL, transformHandler: TransformHandler?, completionHandler: @escaping CompletionHandler) {
        
        // Check if an in-memory cached version of the image exists.
        if var img = self.vinci.cache.objectFromMemory(forKey: url) {
            if let handler = transformHandler {
                img = handler(img)
            }
            
            os_log("Returning memory cached image for %@.", type: .debug, url.path)
            
            completionHandler(img, true)
            return
        }

        // Check the disk cache on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            if var img = self.vinci.cache.object(forKey: url) {
                if let handler = transformHandler {
                    img = handler(img)
                }
                
                os_log("Returning disk cached image for %@.", type: .debug, url.path)
                
                DispatchQueue.main.async {
                    completionHandler(img, true)
                }
                return
            }
            
            // Otherwise, create a data task to fetch the image.
            self.operation = VinciRequestOperation(session: self.vinci.session, url: url) { (image, response, error) in
                
                // If the image is nil, call the completion handler and bail out.
                guard var image = image else {
                    completionHandler(nil, false)
                    return
                }
                
                // Cache the unmodified image.
                let _ = self.vinci.cache.setObject(image, forKey: url)
                
                // If a completion handler is set, execute it and save the result.
                if let handler = transformHandler {
                    image = handler(image)
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
}
