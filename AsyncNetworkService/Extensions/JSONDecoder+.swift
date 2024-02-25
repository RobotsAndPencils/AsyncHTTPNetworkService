//
//  JSONDecoder+.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

public extension JSONDecoder {

    static let networkJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatters: [DateFormatter] = [
                .iso8601,
                .serverDateTimeWithSeconds
            ]
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }()

    static let iso8601JSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // does not handle fractional seconds
        return decoder
    }()

    // includes three digits of fractional seconds e.g. "2020-05-07T22:30:00.000+00:00"
    static let rfc3339WithFractionalSeconds: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601)

        return decoder
    }()

    static let serverDateWithTimeSeconds: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.serverDateTimeWithSeconds)

        return decoder
    }()
}
