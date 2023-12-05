//
//  Data+.swift
//
//  Created by Alex Maslov on 2022-08-15.
//

import Foundation

extension Data {
    internal static let _dash = Data("--".utf8)
    internal static let _crlf = Data("\r\n".utf8)

    public var mimeType: String {
        switch mimeUInt {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        default:
            return "image/jpeg"
        }
    }

    public var fileExtension: String {
        switch mimeUInt {
        case 0xFF:
            return "jpg"
        case 0x89:
            return "png"
        case 0x47:
            return "gif"
        case 0x49, 0x4D:
            return "tiff"
        default:
            return "jpg"
        }
    }

    private var mimeUInt: UInt8 {
        var values = [UInt8](repeating: 0, count: 1)
        copyBytes(to: &values, count: 1)
        return values.first ?? 0
    }
    
    public var jsonString: String? {
        String(data: self, encoding: .utf8)
    }
}
