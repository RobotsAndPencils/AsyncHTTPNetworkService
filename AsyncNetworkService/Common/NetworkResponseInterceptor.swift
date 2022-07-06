//
//  NetworkResponseInterceptor.swift
//  AsyncNetworkService
//
//  Created by Alex Maslov on 2022-07-06.
//

import Foundation

public protocol NetworkResponseInterceptor {
    
    /// Returns true of this interceptor should handle the response
    func shouldHandle(data: Data, response: URLResponse, request: ConvertsToURLRequest) -> Bool
    
    /// Intercepts response and allows interceptor to modify response data before being passed back to original caller.
    /// Should return original response data if no modifications are necessary
    func handle(data: Data, response: URLResponse, request: ConvertsToURLRequest) -> (Data, URLResponse)
}
