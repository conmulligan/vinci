//
//  VinciRequestOperation.swift
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
import UIKit

/// An operation that wraps `VinciRequest` for use in an `OperationQueue`.
class VinciRequestOperation: Operation {

    /// The closure to call when a request finishes.
    typealias CompletionHandler = (UIImage?, URLResponse?, Error?) -> Void

    /// The list of possible operation states.
    enum State: String {
        case ready
        case executing
        case finished

        private var keyPath: String {
            "is" + rawValue
        }
    }

    /// The current operation state.
    var state: State = .ready {
        willSet {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }

    /// Marks the operation as asynchronous.
    override var isAsynchronous: Bool {
        true
    }

    /// Marks the request as executing.
    override var isExecuting: Bool {
        state == .executing
    }

    /// Marks the request as finished.
    override var isFinished: Bool {
        state == .finished
    }

    /// The operation description.
    override var description: String {
        let url = self.dataTask?.currentRequest?.url?.absoluteString ?? "nil"
        return "<\(type(of: self)): URL = \(url)>"
    }

    /// The `URLSession` used to create the data task.
    private var session: URLSession!

    /// The URL of the image to fetch.
    private var url: URL!

    /// The completion handler to call when the request has finished.
    private var completion: CompletionHandler!

    /// The underlying `URLSession` data task.
    private var dataTask: URLSessionDataTask?

    // MARK: - Initialization

    /// Initializes the operation with a URL Session, URL and completion handler.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` to use.
    ///   - url: The URL of the image to fetch.
    ///   - completion: A completion handler which is called when the request finishes.
    init(session: URLSession, url: URL, completion: @escaping CompletionHandler) {
        super.init()

        self.session = session
        self.url = url
        self.completion = completion
    }

    // MARK: - Operation Control

    /// Start the operation.
    override func start() {
        if self.isCancelled {
            state = .finished
            return
        }

        state = .ready
        main()
    }

    /// The operation's body.
    override func main() {
        if isCancelled {
            state = .finished
            return
        }

        state = .executing

        dataTask = session.dataTask(with: url) { (data, response, error) in
            var image: UIImage?

            if let data = data {
                image = UIImage(data: data)
            }

            self.completion(image, response, error)
            self.finish()
        }

        self.dataTask?.resume()
    }

    /// Cancels the operation.
    override func cancel() {
        super.cancel()

        dataTask?.cancel()
        finish()
    }

    /// Finish the operation.
    func finish() {
        if isExecuting {
            state = .finished
        }
    }
}
