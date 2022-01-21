//
//  AsyncNetworkError.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

enum NetworkError: Error {
    case non200StatusCode(statusCode: Int, data: Data?)
    case invalidResponseFormat
    case decoding(error: Error)
    case decodingString
    case noDataInResponse
}
