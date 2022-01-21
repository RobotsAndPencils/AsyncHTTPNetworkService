//
//  URL+.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

extension URL: ConvertsToURLRequest {
    public func asURLRequest() -> URLRequest {
        return URLRequest(url: self)
    }
}
