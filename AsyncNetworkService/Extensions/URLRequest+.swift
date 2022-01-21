//
//  URLRequest+.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

var networkRequestObserverStartDateKey: UInt8 = 0

// MARK: - URL Session task did start
let networkTaskDidStartNotification: AsyncNotification<URLSessionDataTask> = AsyncNotification()
let networkTaskDidCompleteNotification: AsyncNotification<TaskComplete> = AsyncNotification()

extension URLRequest: ConvertsToURLRequest {
    public func asURLRequest() -> URLRequest {
        return self
    }
}

@available(iOS, deprecated: 15.0, message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15")
public extension URLSession {
    /// Start a data task with a URL using async/await.
    /// - parameter url: The URL to send a request to.
    /// - returns: A tuple containing the binary `Data` that was downloaded,
    ///   as well as a `URLResponse` representing the server's response.
    /// - throws: Any error encountered while performing the data task.
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(for: URLRequest(url: url))
    }

    /// Start a data task with a `URLRequest` using async/await.
    /// - parameter request: The `URLRequest` that the data task should perform.
    /// - returns: A tuple containing the binary `Data` that was downloaded,
    ///   as well as a `URLResponse` representing the server's response.
    /// - throws: Any error encountered while performing the data task.
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        var dataTask: URLSessionDataTask?
        let onCancel = { dataTask?.cancel() }

        return try await withTaskCancellationHandler(
            handler: {
                onCancel()
            },
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    dataTask = self.dataTask(with: request) { data, response, error in
                        
                        guard let task = dataTask else { return }
                        guard let date = objc_getAssociatedObject(task, &networkRequestObserverStartDateKey) as? Date else { return }
                        guard let response = response as? HTTPURLResponse else { return }
                        
                        let elapsedTime = Date().timeIntervalSince(date)
                        
                        postNotification(notification: networkTaskDidCompleteNotification, value: TaskComplete(response: response, elapsedTime: elapsedTime))
                        
                        guard let data = data else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: (data, response))
                    }

                    dataTask?.resume()
                    
                    // Posts a notification to time a task
                    guard let task = dataTask else { return }
                    postNotification(notification: networkTaskDidStartNotification, value: task)
                    objc_setAssociatedObject(task, &networkRequestObserverStartDateKey, Date(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        )
    }
}
