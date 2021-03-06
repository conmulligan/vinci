//
//  Vinci.swift
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

/// Represents a Vinci error.
public struct VinciError: Error {
    /// The error message.
    let message: String
}

/// Conform to `LocalizedError`.
extension VinciError: LocalizedError {
    public var errorDescription: String? {
        NSLocalizedString(message, comment: "")
    }
}

/// The Vinci class is the entry point for all requests.
/// It includes a factory method for initializing and configuring `VinciRequest` objects.
open class Vinci {

    /// The `URLSession` used for all requests.
    public let session: URLSession

    /// The shared cache.
    public let cache: VinciCache

    /// Debug mode enabled.
    public var debugEnabled = false

    /// The shared `Vinci` instance.
    public static let shared = Vinci(session: URLSession.shared)

    /// The queue on which all requests are performed.
    private static var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 8
        return queue
    }()

    // MARK: - Initialization

    /// Initialize a new Vinci instance.
    /// - Parameters:
    ///   - session: The URLSession instance.
    ///   - cache: The cache instance.
    public required init(session: URLSession, cache: VinciCache = VinciCache()) {
        self.session = session
        self.cache = cache
    }

    // MARK: - Request Factory

    /// Factory method to create and configure a `VinciRequest` instance.
    ///
    /// - returns: A new `VinciRequest` instance.
    public func request() -> VinciRequest {
        VinciRequest(vinci: self)
    }

    /// Factory method to create and configure a `VinciRequest` instance with the supplied URL,
    /// modifiers and completion handler.
    ///
    /// - Parameters:
    ///   - url: The URL to pass to the request.
    ///   - modifiers: The modifiers to apply.
    ///   - completion: The request completion handler
    /// - Returns: A new `VinciRequest` instance.
    @discardableResult
    public func request(with url: URL,
                        modifiers: [Modifier]?,
                        completion: @escaping VinciRequest.CompletionHandler) -> VinciRequest {
        let request = VinciRequest(vinci: self)
        request.get(url: url, modifiers: modifiers, completion: completion)
        return request
    }

    /// Factory method to create and configure a `VinciRequest` instance with the supplied URL
    /// and completion handler.
    ///
    /// - Parameters:
    ///   - url: The URL to pass to the request.
    /// - Returns: A new `VinciRequest` instance.
    @discardableResult
    public func request(with url: URL, completion: @escaping VinciRequest.CompletionHandler) -> VinciRequest {
        request(with: url, modifiers: nil, completion: completion)
    }

    // MARK: - Operations

    /// Adds an operation to the queue and reweights the queue by assigning a higher priority to the latest operations.
    ///
    /// - parameter operation: An operation to add to the queue.
    internal func addOperation(_ operation: Operation) {
        Vinci.operationQueue.addOperation(operation)

        let operations = Vinci.operationQueue.operations.reversed().enumerated()

        for (index, operation) in operations {
            switch index {
            case 0:
                operation.queuePriority = .veryHigh
            case 1:
                operation.queuePriority = .high
            case 2:
                operation.queuePriority = .normal
            case 3:
                operation.queuePriority = .low
            default:
                operation.queuePriority = .veryLow
            }
        }
    }
}

/// Extend Vinci with helper functions.
extension Vinci {

    // MARK: - Utilities

    /// Generates a URL from the supplied `URL` and `Modifier` instances.
    /// The generated URL uses each modier's `identifier` property to uniquely identify
    /// the modified image.
    ///
    /// - Parameters:
    ///   - url: The base URL of the image resource.
    ///   - modifiers: The modifiers to apply.
    /// - Returns: The generated URL.
    func keyFor(url: URL, modifiers: [Modifier]) -> URL {
        url.appendingPathComponent(modifiers.map { "[\($0.identifier)]" }.joined())
    }
}
