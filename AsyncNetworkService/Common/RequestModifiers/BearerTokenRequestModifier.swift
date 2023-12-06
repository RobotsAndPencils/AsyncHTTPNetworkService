//
//  BearerTokenRequestModifier.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

/// A class to modify a `URLRequest` and insert a header with `Bearer xxx` with a `Authorization` key
public class BearerTokenRequestModifier: HeaderRequestModifier {

    public init(authenticationToken: String) {
        let bearerTokenHeader = "Bearer \(authenticationToken)"
        super.init(key: "Authorization", value: bearerTokenHeader)
    }
}
