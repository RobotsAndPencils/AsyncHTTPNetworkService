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

    public init(data: Data, fieldName: String, additionalContent: [ContentName: ContentValue] = [:], fileName: String) {
        self.data = data
        self.fieldName = fieldName
        self.additionalContent = additionalContent
        self.fileName = fileName
    }
}
