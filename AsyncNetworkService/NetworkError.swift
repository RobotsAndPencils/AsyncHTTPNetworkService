//
//  AsyncNetworkError.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

public enum NetworkError: Error, LocalizedError, Equatable {
    case invalidResponseFormat
    case decoding(error: Error)
    case decodingString
    case noDataInResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case methodNotAllowed
    case timeout
    case serverError
    case other
}

public extension Equatable where Self: Error {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
}

public func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}
