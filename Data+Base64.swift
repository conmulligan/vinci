//
//  String+Base64.swift
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

import Foundation

/// Extends `Data` with base64 URL string encoding methods.
/// https://en.wikipedia.org/wiki/Base64#URL_applications
extension Data {
    
    /// Initializes a `Data` object from a base64 URL encoded string.
    ///
    /// - Parameter string: A base64 URL encoded string.
    init?(base64URLEncoded string: String) {
        let encoded = string
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        let paddingLength = (4 - (encoded.count % 4)) % 4
        let encodedWithPadding = encoded + String(repeating: "=", count: paddingLength)
        self.init(base64Encoded: encodedWithPadding)
    }
    
    /// Initializes a `Data` object from a base64 URL encoded URL.
    ///
    /// - Parameter url: A base64 URL encoded URL.
    init?(base64URLEncoded url: URL) {
        self.init(base64Encoded: url.path)
    }
    
    /// Returns a base 64 URL encoded string representation of this object.
    ///
    /// - Returns: A base64 URL encoded string.
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
    
    /// Returns a base 64 URL encoded URL representation of this object.
    ///
    /// - Returns: A base64 URL encoded string.
    func base64EncodedURL() -> URL {
        guard let url = URL(string: self.base64EncodedString()) else {
            fatalError("The `base64EncodedString` method should always return a valid URL string.")
        }
        return url
    }
}
