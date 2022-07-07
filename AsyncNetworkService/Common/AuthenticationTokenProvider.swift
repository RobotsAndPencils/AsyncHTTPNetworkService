//
//  AuthenticationTokenProvider.swift
//  AsyncNetworkService
//
//  Created by Alex Maslov on 2022-07-06.
//

import Foundation

public protocol AuthenticationTokenProvider: AnyObject {
    var authenticationToken: String { get }
}
