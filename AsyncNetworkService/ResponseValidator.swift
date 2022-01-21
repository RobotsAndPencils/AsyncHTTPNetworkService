//
//  ResponseValidator.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

/// Validates that a response meets certain criteria. If it does not, throws an error.
public typealias ResponseValidator = (HTTPURLResponse, Data?) throws -> Void

public let statusCodeIsIn200s: ResponseValidator = { response, data in
    guard 200 ..< 300 ~= response.statusCode else {
        throw NetworkError.non200StatusCode(statusCode: response.statusCode, data: data)
    }
}
