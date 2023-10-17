//
//  RequestLog.swift
//  
//
//  Created by Paul Alvarez on 12/10/23.
//

import Foundation

public struct RequestLog {
    public let request: URLRequest
    public let response: String
    public let isSuccess: Bool
    public let timestamp = Date()
}
