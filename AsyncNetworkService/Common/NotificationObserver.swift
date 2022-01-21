//
//  NotificationObserver.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation


/// A helper generic struct used in Notifications.
/// A `Notification.name` is a UUID String
public struct AsyncNotification<T> {
    let name: String = UUID().uuidString
    
    /// A NSNotification.Name type used in Swift notifications
    var notificationName: NSNotification.Name {
        return NSNotification.Name(rawValue: name)
    }
}

public class NotificationObserver {
    let observer: NSObjectProtocol
    
    init<T>(notification: AsyncNotification<T>, block aBlock: @escaping (T) -> ()) {
        observer = NotificationCenter.default.addObserver(forName: notification.notificationName, object: nil, queue: nil) { note in
            if let value = (note.userInfo?["value"] as? UserInfoContainer<T>)?.rawValue {
                aBlock(value)
            } else {
                assert(false, "Couldn't understand user info")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
}

/// A helper class used in Notifications.
/// This wraps the userinfo property `value` so it can be used in generics
class UserInfoContainer<T> {
    let rawValue: T
    init(_ value: T) { self.rawValue = value }
}

func postNotification<T>(notification: AsyncNotification<T>, value: T) {
    let userInfo = ["value": UserInfoContainer(value)]
    NotificationCenter.default.post(name: notification.notificationName, object: nil, userInfo: userInfo)
}

protocol BearerTokenAware {
    var authenticationToken: String { get set }
}

// MARK: - Refresh Token Notification
/// A AsyncNotification type that is used to notify services of when a token has refreshed.
let refreshTokenNotification: AsyncNotification<String> = AsyncNotification()
