import Foundation
import UIKit

@testable import AsyncNetworkService

extension URLRequest {
    static func stub() -> URLRequest {
        return URLRequest(url: .stub())
    }
}

extension URL {
    static func stub() -> URL {
        return URL(string: "http://www.google.com")!
    }
    
    static func modifiedStub() -> URL {
        return URL(string: "http://www.google.com/modified")!
    }
}

extension UIImage {
    static func stub() -> UIImage {
        let imageSize = CGSize(width: 5, height: 5)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1)
        let context = UIGraphicsGetCurrentContext()!

        let rectangle = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)

        context.setFillColor(UIColor.red.cgColor)
        context.addRect(rectangle)
        context.drawPath(using: .fill)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension String {
    static var original: String = "original"
    static var modified: String = "modified"
}

extension URLResponse {
    static var originalStub: URLResponse {
        URLResponse(url: .stub(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    static var modifiedStub: URLResponse {
        URLResponse(url: .modifiedStub(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}

extension Data {
    static var originalStub: Data {
        String.original.data(using: .utf8)!
    }
    
    static var modifiedStub: Data {
        String.modified.data(using: .utf8)!
    }
}
