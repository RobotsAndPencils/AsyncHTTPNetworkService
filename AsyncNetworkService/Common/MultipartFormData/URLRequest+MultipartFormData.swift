//
//  URLRequest+MultipartFormData.swift
//  swift-multipart-formdata
//
//  Created by Felix Herrmann on 29.12.21.
//

import Foundation

extension URLRequest {
    /// Creates a `URLRequest` from a ``MultipartFormData``.
    ///
    /// This initializer will set the `httpMethod` to `"POST"` and configures header and
    /// body appropriately for the multipart/form-data.
    ///
    /// - Parameters:
    ///   - url: The URL for the request.
    ///   - multipartFormData: The multipart/form-data for the request.
    public init(url: URL, multipartFormData: MultipartFormData) {
        self.init(url: url)
        httpMethod = "POST"
        updateHeaderField(with: multipartFormData.contentType)
        httpBody = multipartFormData.httpBody
    }
}

// MARK: - Updates

extension URLRequest {
    /// This method configures header and body appropriately for the multipart/form-data.
    ///
    /// - Parameters:
    ///   - multipartFormData: The multipart/form-data for the request.
    public mutating func update(with multipartFormData: MultipartFormData) {
        updateHeaderField(with: multipartFormData.contentType)
        httpBody = multipartFormData.httpBody
    }

    /// Updates the corresponding header field with a``HTTPHeaderField`` object.
    /// - Parameter headerField: The new header field object.
    public mutating func updateHeaderField<Field: HTTPHeaderField>(with headerField: Field) {
        setValue(headerField._value, forHTTPHeaderField: Field.name)
    }
}
