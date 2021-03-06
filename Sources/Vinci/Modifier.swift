//
//  Modifier.swift
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

import Foundation
import UIKit

/// Modify a `UIImage` instance in some way.
public protocol Modifier {

    /// A unique identiier.
    var identifier: String { get }

    /// Modifies the supplied image and returns the result.
    /// - Parameter image: The modified image.
    func modify(image: UIImage) -> UIImage
}

/// Modifies an image using a custom closure.
open class ClosureModifier: Modifier {
    public var identifier: String
    var closure: (_ image: UIImage) -> UIImage

    public init(identifier: String, closure: @escaping (_ image: UIImage) -> UIImage) {
        self.identifier = identifier
        self.closure = closure
    }

    public func modify(image: UIImage) -> UIImage {
        return closure(image)
    }
}

/// Scales an image to a specific size.
open class ScaleModifier: Modifier {
    public var identifier: String {
        "vinci.scale.\(size.width)x\(size.height)"
    }

    public var size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public func modify(image: UIImage) -> UIImage {
        return image.scaledTo(size)
    }
}

/// Creates a thumbnail of the original image.
open class ThumbnailModifier: Modifier {
    public var identifier: String {
        return "vinci.thumbnail.\(size.width)x\(size.height)"
    }

    public var size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public func modify(image: UIImage) -> UIImage {
        return image.thumbailImage(size)
    }
}

/// Remaps colors so they fall within shades of a single color using CIColorMonochrome.
/// The default color is black.
open class MonoModifier: Modifier {
    public var identifier: String {
        return "vinci.mono.\(color.hexString)_\(intensity)"
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

    public func modify(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let ciImage = CIImage(cgImage: cgImage)

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIColor(color: color), forKey: kCIInputColorKey)
        filter?.setValue(intensity, forKey: kCIInputIntensityKey)

        guard let output = filter?.outputImage, let cgi = CIContext().createCGImage(output, from: output.extent) else {
            return image
        }

        return UIImage(cgImage: cgi)
    }
}
