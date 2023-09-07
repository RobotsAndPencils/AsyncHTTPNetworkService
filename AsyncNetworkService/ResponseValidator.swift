//
//  ResponseValidator.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

/// Validates that a response meets certain criteria. If it does not, throws an error.
public typealias ResponseValidator = (HTTPURLResponse, Data?) throws -> Void

public let responseValidator: ResponseValidator = { response, data in
    switch response.statusCode {
    case 200..<300:
        return
    case 400:
        throw NetworkError.badRequest(contextualizedDescription: nil)
    case 401:
        throw NetworkError.unauthorized(contextualizedDescription: nil)
    case 403:
        throw NetworkError.forbidden(contextualizedDescription: nil)
    case 404:
        throw NetworkError.notFound(contextualizedDescription: nil)
    case 408:
        throw NetworkError.timeout(contextualizedDescription: nil)
    case 500..<600:
        throw NetworkError.serverError(contextualizedDescription: nil)
    default:
        throw NetworkError.other(contextualizedDescription: nil)
    }
}
