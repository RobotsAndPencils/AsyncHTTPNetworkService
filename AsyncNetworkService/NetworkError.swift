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
    case badRequest(contextualizedDescription: String? = nil)
    case unauthorized(contextualizedDescription: String? = nil)
    case forbidden(contextualizedDescription: String? = nil)
    case notFound(contextualizedDescription: String? = nil)
    case timeout(contextualizedDescription: String? = nil)
    case serverError(contextualizedDescription: String? = nil)
    case other(contextualizedDescription: String? = nil)
    
    public var errorDescription: String? {
        switch self {
        case .badRequest(let contextualizedDescription):
            return contextualizedDescription
        case .unauthorized(let contextualizedDescription):
            return contextualizedDescription
        case .forbidden(let contextualizedDescription):
            return contextualizedDescription
        case .notFound(let contextualizedDescription):
            return contextualizedDescription
        case .timeout(let contextualizedDescription):
            return contextualizedDescription
        case .serverError(let contextualizedDescription):
            return contextualizedDescription
        case .other(let contextualizedDescription):
            return contextualizedDescription
        default:
            return nil
        }
    }
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
