//
//  JSONDecoder+.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

extension JSONDecoder {
    public static let networkJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // does not handle fractional seconds
        return decoder
    }()
    
    // includes three digits of fractional seconds e.g. "2020-05-07T22:30:00.000+00:00"
    public static let rfc3339WithFractionalSeconds: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601)
        
        return decoder
    }()
}
