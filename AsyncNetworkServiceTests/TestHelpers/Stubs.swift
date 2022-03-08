import Foundation
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
