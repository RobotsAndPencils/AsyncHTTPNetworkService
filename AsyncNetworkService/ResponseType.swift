//
//  ResponseType.swift
//  
//
//  Created by Paul Alvarez on 22/11/23.
//

import Foundation

public enum ResponseType {
    case object(Decodable.Type)
    case string
}
