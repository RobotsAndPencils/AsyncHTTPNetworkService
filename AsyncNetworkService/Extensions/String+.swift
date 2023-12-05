//
//  String+.swift
//  AsyncNetworkService
//
//  Created by Alex Maslov on 2023-05-05.
//

import Foundation
import UniformTypeIdentifiers

extension NSString {
    public var mimeType: String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

extension String {
    public var mimeType: String {
        return (self as NSString).mimeType
    }
}

// MARK: - StaticString
extension String {
    internal init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
    }
}
