//
//  AsyncNetworkHandler.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

public protocol AsyncNetworkErrorHandler {
    func canHandle(_ error: Error) -> Bool
    func handle(_ error: Error) async throws
}

struct TaskComplete {
    let response: HTTPURLResponse?
    let elapsedTime: TimeInterval?
}
