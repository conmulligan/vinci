//
//  UIImage+Modify.swift
//  Vinci
//
//  Created by Conor Mulligan on 14/07/2018.
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
#if canImport(UIKit)
import UIKit
#endif

/// Extend `UIImage` with convenience modifiier methods.
extension UIImage {
    
    /// Returns a copy of the current image scaled to the supplied size.
    ///
    /// - Parameter targetSize: The new image size.
    /// - Returns: The scaled image.
    func scaledImage(_ targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let aspectWidth = targetSize.width  / self.size.width
        let aspectHeight = targetSize.height / self.size.height
        
        var newSize: CGSize
        
        if (aspectWidth > aspectHeight) {
            newSize = CGSize(width: size.width * aspectHeight, height: size.height * aspectHeight)
        } else {
            newSize = CGSize(width: size.width * aspectWidth,  height: size.height * aspectWidth)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    /// Returns a copy of the current image with the larger dimension
    /// center-cropped to the size of the smaller dimension.
    ///
    /// - Returns: The squared image.
    func squareImage() -> UIImage {
        let size  = self.size
        
        var edge: CGFloat
        if size.width > size.height {
            edge = size.height
        } else {
            edge = size.width
        }
        
        let x = (size.width - edge) / 2.0
        let y = (size.height - edge) / 2.0
        
        let rect = CGRect(x: x, y: y, width: edge, height: edge)
        
        let imageRef = self.cgImage?.cropping(to: rect);
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: self.imageOrientation)
    }
    
    func thumbailImage(_ size: CGSize) -> UIImage {
        return self.scaledImage(size).squareImage()
    }
}

