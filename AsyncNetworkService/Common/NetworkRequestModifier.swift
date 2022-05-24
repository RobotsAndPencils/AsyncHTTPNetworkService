//
//  NetworkRequestModifier.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

/// Represents a type that adds persistent details to a URL Request. (Ex: adding headers with authentication)
public protocol NetworkRequestModifier {
    /// Add authentication details to a URL Request (for example, by adding authentication headers)
    ///
    /// - returns: The modified URL Request
    func mutate(_ request: URLRequest) -> URLRequest
}

/// Types adopting the `ConvertsToURLRequest` protocol can be used to construct URL requests.
public protocol ConvertsToURLRequest {
    /// - returns: A URL request.
    func asURLRequest() -> URLRequest
}

public extension NetworkRequestModifier {
    func mutate(_ requestModifiable: ConvertsToURLRequest) -> URLRequest {
        let urlRequest = requestModifiable.asURLRequest()
        return mutate(urlRequest)
    }
}
