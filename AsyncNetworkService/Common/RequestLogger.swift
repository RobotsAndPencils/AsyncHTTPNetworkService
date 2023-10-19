//
//  RequestLogger.swift
//  
//
//  Created by Paul Alvarez on 17/10/23.
//

import Foundation

public final class RequestLogger {
    public static let shared = RequestLogger()

    public var logs: [RequestLog] = []

    func log(request: RequestLog) {
        logs.append(request)
    }
}
