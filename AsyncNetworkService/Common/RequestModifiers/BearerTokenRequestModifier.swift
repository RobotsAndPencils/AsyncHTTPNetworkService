//
//  BearerTokenRequestModifier.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

/// A class to modify a `URLRequest` and insert a header with `Bearer xxx` with a `Authorization` key
public class BearerTokenRequestModifier: NetworkRequestModifier {
    private var authenticationToken: String
    public init(authenticationToken: String) {
        self.authenticationToken = authenticationToken
    }

    public func mutate(_ request: URLRequest) -> URLRequest {
        var mutableRequest = request
        let bearerTokenHeader = "Bearer \(authenticationToken)"
        mutableRequest.setValue(bearerTokenHeader, forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
}
