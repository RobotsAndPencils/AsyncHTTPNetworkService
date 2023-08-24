//
//  AsyncNetworkError.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

public enum NetworkError: Error, LocalizedError, Equatable {
    case non200StatusCode(statusCode: Int, data: Data?)
    case invalidResponseFormat
    case decoding(error: Error)
    case decodingString
    case noDataInResponse
    case noInternetConnection
    case timeout
    case serverError
    case unauthorized
    case forbidden
    case notFound
    case badRequest
    case other(Error)
    
    public var errorDescription: String? {
        switch self {
        case .non200StatusCode(let statusCode, _):
            return "Received non-200 HTTP status code: \(statusCode)"
        case .invalidResponseFormat:
            return "Invalid response format"
        case .decoding(_):
            return "Error while decoding response data"
        case .decodingString:
            return "Error while decoding a string"
        case .noDataInResponse:
            return "No data in server response"
        case .noInternetConnection:
            return "No internet connection available"
        case .timeout:
            return "Request timed out"
        case .serverError:
            return "Internal server error"
        case .unauthorized:
            return "You're not authorized to perform this request"
        case .forbidden:
            return "Access to the requested resource is forbidden"
        case .notFound:
            return "Requested resource not found"
        case .badRequest:
            return "Invalid request formed"
        case .other(let error):
            return error.localizedDescription
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
