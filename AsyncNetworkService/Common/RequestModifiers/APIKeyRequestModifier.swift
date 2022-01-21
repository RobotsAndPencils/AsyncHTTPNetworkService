//
//  APIKeyRequestModifier.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

public class APIKeyRequestModifier: NetworkRequestModifier {
    private var apiKey: String
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func mutate(_ request: URLRequest) -> URLRequest {
        guard
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return request
        }
        //
        let apiKey = URLQueryItem(name: "api_key", value: apiKey)
        
        var queryItems: [URLQueryItem] = components.queryItems ?? []
        queryItems.append(apiKey)
        components.queryItems = queryItems
        
        guard let newURL = components.url else {
            assertionFailure("Expected to be able to add a query item to the URL without breaking it")
            return request
        }
        
        var newRequest = request
        newRequest.url = newURL
        return newRequest
    }
}
