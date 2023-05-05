//
//  UploadableImage.swift
//  AsyncNetworkService
//
//  Created by Alex Maslov on 2022-08-23.
//

import Foundation

public typealias ContentName = String
public typealias ContentValue = String

public struct UploadableFile {
    public let data: Data
    public let fieldName: String
    public let additionalContent: [ContentName: ContentValue]
    public let fileName: String

    /// Creates an object representation of a file with associated data required for a POST upload
    ///
    /// ```
    /// UploadableFile(data: pdfData, fileName: "myfile.pdf")
    /// ```
    ///
    /// - Parameters:
    ///   - data: Raw file data
    ///   - fileName: The name of the file. This will be used in the `Content-Disposition` header on a POST request. Ensure the file extension is specified as the framework relies on it to resolve the MimeType.
    ///   - fieldName: The value for `name` property in the `Content-Disposition` header
    ///   - additionalContent: Additional key value pairs that will be appended to the `Content-Disposition` header as properties
    ///
    ///
    /// - Returns: Void if deletion succeeds
    ///
    /// - Throws: `NetworkError` if deletion fails
    
    public init(data: Data, fileName: String, fieldName: String = "files", additionalContent: [ContentName: ContentValue] = [:]) {
        self.data = data
        self.fieldName = fieldName
        self.additionalContent = additionalContent
        self.fileName = fileName
    }
}
