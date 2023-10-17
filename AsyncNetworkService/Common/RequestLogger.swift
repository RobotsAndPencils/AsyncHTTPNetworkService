//
//  RequestLogger.swift
//  
//
//  Created by Paul Alvarez on 17/10/23.
//

import Foundation

class RequestLogger {
    static var shared = RequestLogger()

    public var logs: [RequestLog] = []

    func log(request: URLRequest, responseData: Data?, isSuccess: Bool) {
        var jsonString = ""
        if let responseData = responseData {
            jsonString = String(decoding: responseData, as: UTF8.self)
        }

        logs.append(
            RequestLog(
                request: request,
                response: jsonString,
                isSuccess: isSuccess
            )
        )
    }
}
