//
//  String+MD5.swift
//  Pods-Vinci_Example
//
//  Created by Conor Mulligan on 20/03/2020.
//

import Foundation
import CryptoKit

extension String {

    /// Returns an MD5 hash represenation of the current string.
    var MD5: String {
        let data = Data(self.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
