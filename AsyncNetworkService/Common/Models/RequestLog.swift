//
//  RequestLog.swift
//  
//
//  Created by Paul Alvarez on 12/10/23.
//

import Foundation

public struct RequestLog {
    public let request: URLRequest
    public let response: String?
    public let isSuccess: Bool
    public let timestamp = Date()

    init(request: URLRequest, response: String?, isSuccess: Bool) {
        self.request = request
        self.response = response
        self.isSuccess = isSuccess
    }

    init(request: URLRequest, responseData: Data?, isSuccess: Bool) {
        var jsonString: String? = nil
        if let responseData = responseData {
            jsonString = String(decoding: responseData, as: UTF8.self)
        }
        self.request = request
        self.response = jsonString
        self.isSuccess = isSuccess
    }
}
