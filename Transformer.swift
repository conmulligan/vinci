//
//  Transformer.swift
//  Vinci
//
//  Created by Conor Mulligan on 12/06/2018.
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

import UIKit
import CoreImage

/// Transformers modify a `UIImage` instance in some way.
public protocol Transformer {
    var identifier: String { get }
    
    func doTransform(image: UIImage) -> UIImage
}

/// Transforms an image using a custom closure.
open class ClosureTransformer: Transformer {
    public var identifier: String
    var closure: (_ image: UIImage) -> UIImage
    
    public init(identifier: String, closure: @escaping (_ image: UIImage) -> UIImage) {
        self.identifier = identifier
        self.closure = closure
    }
    
    public func doTransform(image: UIImage) -> UIImage {
        return self.closure(image)
    }
}

/// Scales an image to a specific size.
open class ScaleTransformer: Transformer {
    public var identifier: String
    public var size: CGSize
    
    public init(size: CGSize) {
        self.identifier = "vinci.scale"
        self.size = size
    }
    
    public func doTransform(image: UIImage) -> UIImage {
        return image.scaledImage(self.size)
    }
}

/// Desaturates an image using a `CoreImage` filter.
open class DesaturateTransformer: Transformer {
    public var identifier: String
    
    public init() {
        self.identifier = "vinci.desaturate"
    }
    
    public func doTransform(image: UIImage) -> UIImage {
        let ciImage = CIImage(cgImage: image.cgImage!)
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        filter?.setValue(CIColor.black, forKey: kCIInputColorKey)
        filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        
        guard let outputImage = filter?.outputImage else {
            return image
        }
        
        guard let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
}
