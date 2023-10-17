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
        if let responseData = responseData,
           let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
           let jsonStringData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
            jsonString = String(data: jsonStringData, encoding: .utf8) ?? ""
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
