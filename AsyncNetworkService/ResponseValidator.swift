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
        throw NetworkError.badRequest()
    case 401:
        throw NetworkError.unauthorized()
    case 403:
        throw NetworkError.forbidden()
    case 404:
        throw NetworkError.notFound()
    case 408:
        throw NetworkError.timeout()
    case 422:
        throw NetworkError.unprocessableContent()
    case 500..<600:
        throw NetworkError.serverError()
    default:
        throw NetworkError.other()
    }
}
