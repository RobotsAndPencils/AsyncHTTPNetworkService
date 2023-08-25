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
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponseFormat:
            return "Invalid response format"
        case .decoding(_):
            return "Error while decoding response data"
        case .decodingString:
            return "Error while decoding a string"
        case .noDataInResponse:
            return "No data in server response"
        case .badRequest:
            return "Oops! Something went wrong with your request. Please try again."
        case .unauthorized:
            return "You need to sign in to perform this action."
        case .forbidden:
            return "Sorry, you don't have permission to do this."
        case .notFound:
            return "We couldn't find what you're looking for."
        case .methodNotAllowed:
            return "Sorry, you can't do that right now."
        case .timeout:
            return "Your request timed out. Please check your connection and try again."
        case .serverError:
            return "Something went wrong on our end. We're working to fix it."
        case .other:
            return "An error ocurred"
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
