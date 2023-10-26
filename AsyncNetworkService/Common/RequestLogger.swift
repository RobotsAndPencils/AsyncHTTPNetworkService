//
//  RequestLogger.swift
//  
//
//  Created by Paul Alvarez on 17/10/23.
//

import Foundation

public final class RequestLogger {
    public static let shared = RequestLogger()
    private let queue = DispatchQueue(label: "com.dustidentity.RequestLoggerQueue")

    public var logs: [RequestLog] = []

    func log(request: RequestLog) {
        queue.async {
            self.logs.append(request)
        }
    }
}
