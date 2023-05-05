//
//  ImageUploadRequestModifier.swift
//  AsyncNetworkService
//
//  Created by Alex Maslov on 2022-08-23.
//

import Foundation

struct FileUploadRequestModifier: NetworkRequestModifier {
    let files: [UploadableFile]
    let boundary: String

    public func mutate(_ request: URLRequest) -> URLRequest {
        var updatedRequest = request.asURLRequest()

        updatedRequest.setValue("multipart/form-data;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        updatedRequest.httpBody = fileContentData

        return updatedRequest
    }

    
    private var fileContentData: Data {
        var combinedData = Data()
        files.forEach {
            var postContent = ""
            let fileName = "\($0.fileName)"

            postContent += "\r\n"
            postContent += "--\(boundary)"
            postContent += "\r\n"
            postContent += "Content-Disposition: form-data; name=\"\($0.fieldName)\"; filename=\"\(fileName)\"\r\n"
            postContent += "Content-Type: \($0.fileName.mimeType)"
            postContent += "\r\n\r\n"
            
            guard let postData = postContent.data(using: .utf8) else { return }
            combinedData.append(postData)
            combinedData.append($0.data)
            
            combinedData.append(additionalContentData(additionalContent: $0.additionalContent))
        }
        guard let endBoundryData = ("\r\n--\(boundary)--\r\n").data(using: .utf8) else { return combinedData }
        combinedData.append(endBoundryData)

        return combinedData
    }

    private func additionalContentData(additionalContent: [ContentName: ContentValue]) -> Data {
        var postContent = ""
        additionalContent.forEach {
            postContent += "\r\n"
            postContent += "--\(boundary)"
            postContent += "\r\n"
            postContent += "Content-Disposition: form-data; name=\"\($0.key)\""
            postContent += "\r\n\r\n"
            postContent += "\($0.value)"
        }
        return postContent.data(using: .utf8) ?? Data()
    }
}
