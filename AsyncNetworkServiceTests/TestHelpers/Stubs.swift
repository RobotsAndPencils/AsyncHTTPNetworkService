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
