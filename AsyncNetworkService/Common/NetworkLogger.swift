//
//  NetworkLogger.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation
import os.log

public protocol NetworkLogger {
    /// The logging function
    func log(
        // sourcery: SaveParameters
        _ message: String,
        // sourcery: SaveParameters
        type: OSLogType,
        log: OSLog,
        sender: String
    )
}

class ConsoleLogger: NetworkLogger {
    static var shared: ConsoleLogger = .init()

    func log(_ message: String, type: OSLogType, log: OSLog = .default, sender: String) {
        let emoji: String

        switch type {
        case .default: emoji = "➡️"
        case .debug: emoji = "✳️"
        case .info: emoji = "✏️"
        case .fault: emoji = "⚠️"
        case .error: emoji = "❌"
        default:
            emoji = "✳️"
        }

        os.os_log(
            "%@: receive %@",
            log: log,
            type: type,
            emoji,
            "\(sender): \(message)"
        )
    }
}
