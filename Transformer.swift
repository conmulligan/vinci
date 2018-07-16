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
    public var identifier: String {
        return "vinci.scale.\(self.size.width)x\(self.size.height)"
    }
    
    public var size: CGSize
    
    public init(size: CGSize) {
        self.size = size
    }
    
    public func doTransform(image: UIImage) -> UIImage {
        return image.scaledImage(self.size)
    }
}

/// Remaps colors so they fall within shades of a single color using CIColorMonochrome.
/// The default color is black.
open class MonoTransformer: Transformer {
    // TODO: Use a shorter color ID; e.g. a hex code.
    public var identifier: String {
        return "vinci.mono.\(self.color.hexString)_\(self.intensity)"
    }
    
    public var color = UIColor.black
    public var intensity: Float = 1.0
    
    public init() {
        
    }
    
    public convenience init(color: UIColor) {
        self.init()
        self.color = color
    }
    
    public convenience init(color: UIColor, intensity: Float) {
        self.init()
        self.color = color
        self.intensity = intensity
    }
    
    public func doTransform(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIColor(color: self.color), forKey: kCIInputColorKey)
        filter?.setValue(self.intensity, forKey: kCIInputIntensityKey)
        
        guard let output = filter?.outputImage, let cgi = CIContext().createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgi)
    }
}
