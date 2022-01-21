//
//  Codable+.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation
extension Encodable {
    /**
     Convert this object to json data
     
     - parameter outputFormatting: The formatting of the output JSON data (compact or pritty printed)
     - parameter dateEncodingStrategy: how do you want to format the date
     - parameter dataEncodingStrategy: what kind of encoding. base64 is the default
     
     - returns: The json data
     */
    func serializeToJSON(
        outputFormatting: JSONEncoder.OutputFormatting = [],
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormatting
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.dataEncodingStrategy = dataEncodingStrategy
        return try encoder.encode(self)
    }
    
    /**
     Convert this object to a json string
     
     - parameter outputFormatting: The formatting of the output JSON data (compact or pritty printed)
     - parameter dateEncodingStrategy: how do you want to format the date
     - parameter dataEncodingStrategy: what kind of encoding. base64 is the default
     
     - returns: The json string
     */
    func toJSON(
        outputFormatting: JSONEncoder.OutputFormatting = [],
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64
    ) throws -> String? {
        let data = try serializeToJSON(outputFormatting: outputFormatting, dateEncodingStrategy: dateEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy)
        return String(data: data, encoding: .utf8)
    }
    
    /**
     Save this object to a file in the temp directory
     
     - parameter fileName: The filename
     
     - returns: Nothing
     */
    func saveAsJSONTo(_ fileURL: URL) throws {
        try serializeToJSON().write(to: fileURL, options: .atomic)
    }
    /**
     Converts this object to a dictionary
     */
    func toDictionary() -> [String: AnyObject] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: AnyObject] ?? [:]
    }
}


extension Decodable {
    /**
     Create an instance of this type from a json string
     
     - parameter data: The json data
     */
    init(jsonData: Data, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        self = try decoder.decode(Self.self, from: jsonData)
    }
    
    /**
     Initialize this object from an archived file from an URL
     
     - parameter fileNameInTemp: The filename
     */
    init(fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        try self.init(jsonData: data)
    }
    init(fileURL: URL, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) throws {
        let data = try Data(contentsOf: fileURL)
        try self.init(jsonData: data, dateDecodingStrategy: dateDecodingStrategy)
    }
}

// Generic decoder for dictionarys

extension KeyedDecodingContainer {
    
    func decodeAny<T>(_ type: T.Type, forKey key: K) throws -> T {
        guard let value = try decode(AnyCodable.self, forKey: key).value as? T else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding of \(T.self) failed"))
        }
        return value
    }
    
    func decodeAnyIfPresent<T>(_ type: T.Type, forKey key: K) throws -> T? {
        if !contains(key) {
            return nil
        }
        
        return try decodeAny(type, forKey: key)
    }
    
    func toDictionary() throws -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for key in allKeys {
            dictionary[key.stringValue] = try decodeAny(key)
        }
        return dictionary
    }
    
    // codable
    func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        return try decode(T.self, forKey: key)
    }
    
    func decodeIfPresent<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T: Decodable {
        return try decodeIfPresent(T.self, forKey: key)
    }
    
    // any
    func decodeAny<T>(_ key: K) throws -> T {
        return try decodeAny(T.self, forKey: key)
    }
    
    func decodeAnyIfPresent<T>(_ key: K) throws -> T? {
        return try decodeAnyIfPresent(T.self, forKey: key)
    }
    
    // array
    func decodeArray<T: Decodable>(_ key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [T] {
        return try decodeArray([T].self, forKey: key, invalidElementStrategy: invalidElementStrategy)
    }
    
    func decodeArrayIfPresent<T: Decodable>(_ key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [T]? {
        return try decodeArrayIfPresent([T].self, forKey: key, invalidElementStrategy: invalidElementStrategy)
    }
    
    // dictionary
    func decodeDictionary<T: Decodable>(_ key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [String: T] {
        return try decodeDictionary([String: T].self, forKey: key, invalidElementStrategy: invalidElementStrategy)
    }
    
    func decodeDictionaryIfPresent<T: Decodable>(_ key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [String: T]? {
        return try decodeDictionaryIfPresent([String: T].self, forKey: key, invalidElementStrategy: invalidElementStrategy)
    }
}

extension UnkeyedDecodingContainer {
    
    mutating func decode<T: Decodable>() throws -> T {
        return try decode(T.self)
    }
    
    mutating func decodeIfPresent<T: Decodable>() throws -> T? {
        return try decodeIfPresent(T.self)
    }
}

enum InvalidElementStrategy<T>: CustomStringConvertible {
    case remove
    case fail
    case fallback(T)
    case custom((DecodingError) -> InvalidElementStrategy<T>)
    
    func decodeItem(onError: ((Error) -> ())? = nil, decode: () throws -> T) throws -> T? {
        do {
            return try decode()
        } catch {
            onError?(error)
            switch self {
                case .remove:
                    return nil
                case .fail:
                    throw error
                case let .fallback(value):
                    return value
                case let .custom(getBehaviour):
                    guard let decodingError = error as? DecodingError else { throw error }
                    let behaviour = getBehaviour(decodingError)
                    return try behaviour.decodeItem(onError: onError, decode: decode)
            }
        }
    }
    
    func toType<T>() -> InvalidElementStrategy<T> {
        switch self {
            case .remove:
                return .remove
            case .fail:
                return .fail
            case let .fallback(value):
                if let value = value as? T {
                    return .fallback(value)
                } else {
                    return .fail
                }
            case let .custom(getBehaviour):
                return .custom( { error in
                    getBehaviour(error).toType()
                })
        }
    }
    
    public var description: String {
        switch self {
            case .remove:
                return "remove"
            case .fail:
                return "fail"
            case .fallback:
                return "fallback"
            case .custom:
                return "custom"
        }
    }
}

extension KeyedDecodingContainer {
    
    func decodeArray<T: Decodable>(_ type: [T].Type, forKey key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [T] {
        var container = try nestedUnkeyedContainer(forKey: key)
        var chosenInvalidElementStrategy: InvalidElementStrategy<T>
        if let invalidElementStrategy = invalidElementStrategy {
            chosenInvalidElementStrategy = invalidElementStrategy
        } else if let invalidElementStrategy = try superDecoder().userInfo[.invalidElementStrategy] as? InvalidElementStrategy<Any> {
            chosenInvalidElementStrategy = invalidElementStrategy.toType()
        } else {
            chosenInvalidElementStrategy = .fail
        }
        
        var array: [T] = []
        while !container.isAtEnd {
            let element: T? = try chosenInvalidElementStrategy.decodeItem(onError: { _ in
                // hack to advance the current index
                _ = try? container.decode(AnyCodable.self)
            }) {
                try container.decode(T.self)
            }
            if let element = element {
                array.append(element)
            }
        }
        return array
    }
    
    func decodeArrayIfPresent<T: Decodable>(_ type: [T].Type, forKey key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [T]? {
        if !contains(key) {
            return nil
        }
        return try decodeArray(type, forKey: key, invalidElementStrategy: invalidElementStrategy)
    }
    
    func decodeDictionary<T: Decodable>(_ type: [String: T].Type, forKey key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [String: T] {
        let container = try self.nestedContainer(keyedBy: RawCodingKey.self, forKey: key)
        
        var chosenInvalidElementStrategy: InvalidElementStrategy<T>
        if let invalidElementStrategy = invalidElementStrategy {
            chosenInvalidElementStrategy = invalidElementStrategy
        } else if let invalidElementStrategy = try superDecoder().userInfo[.invalidElementStrategy] as? InvalidElementStrategy<Any> {
            chosenInvalidElementStrategy = invalidElementStrategy.toType()
        } else {
            chosenInvalidElementStrategy = .fail
        }
        
        var dictionary: [String: T] = [:]
        for key in container.allKeys {
            
            let element: T? = try chosenInvalidElementStrategy.decodeItem {
                try container.decode(T.self, forKey: key)
            }
            if let element = element {
                dictionary[key.stringValue] = element
            }
        }
        return dictionary
    }
    
    func decodeDictionaryIfPresent<T: Decodable>(_ type: [String: T].Type, forKey key: K, invalidElementStrategy: InvalidElementStrategy<T>? = nil) throws -> [String: T]? {
        if !contains(key) {
            return nil
        }
        return try decodeDictionary(type, forKey: key, invalidElementStrategy: invalidElementStrategy)
    }
}

extension CodingUserInfoKey {
    static let invalidElementStrategy = CodingUserInfoKey(rawValue: "invalidElementStrategy")!
}

// Based on https://github.com/Flight-School/AnyCodable
/**
 A type-erased `Codable` value.
 
 You can encode or decode mixed-type or unknown values in dictionaries
 and other collections that require `Encodable` or `Decodable` conformance
 by declaring their contained type to be `AnyCodable`.
 */
struct AnyCodable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

extension AnyCodable: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.value {
            case is Void:
                try container.encodeNil()
            case let bool as Bool:
                try container.encode(bool)
            case let int as Int:
                try container.encode(int)
            case let int8 as Int8:
                try container.encode(int8)
            case let int16 as Int16:
                try container.encode(int16)
            case let int32 as Int32:
                try container.encode(int32)
            case let int64 as Int64:
                try container.encode(int64)
            case let uint as UInt:
                try container.encode(uint)
            case let uint8 as UInt8:
                try container.encode(uint8)
            case let uint16 as UInt16:
                try container.encode(uint16)
            case let uint32 as UInt32:
                try container.encode(uint32)
            case let uint64 as UInt64:
                try container.encode(uint64)
            case let float as Float:
                try container.encode(float)
            case let double as Double:
                try container.encode(double)
            case let string as String:
                try container.encode(string)
            case let date as Date:
                try container.encode(date)
            case let url as URL:
                try container.encode(url)
            case let array as [Any?]:
                try container.encode(array.map { AnyCodable($0) })
            case let dictionary as [String: Any?]:
                try container.encode(dictionary.mapValues { AnyCodable($0) })
            default:
                let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
                throw EncodingError.invalidValue(self.value, context)
        }
    }
}

extension AnyCodable: Equatable {
    static func ==(lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
            case is (Void, Void):
                return true
            case let (lhs as Bool, rhs as Bool):
                return lhs == rhs
            case let (lhs as Int, rhs as Int):
                return lhs == rhs
            case let (lhs as Int8, rhs as Int8):
                return lhs == rhs
            case let (lhs as Int16, rhs as Int16):
                return lhs == rhs
            case let (lhs as Int32, rhs as Int32):
                return lhs == rhs
            case let (lhs as Int64, rhs as Int64):
                return lhs == rhs
            case let (lhs as UInt, rhs as UInt):
                return lhs == rhs
            case let (lhs as UInt8, rhs as UInt8):
                return lhs == rhs
            case let (lhs as UInt16, rhs as UInt16):
                return lhs == rhs
            case let (lhs as UInt32, rhs as UInt32):
                return lhs == rhs
            case let (lhs as UInt64, rhs as UInt64):
                return lhs == rhs
            case let (lhs as Float, rhs as Float):
                return lhs == rhs
            case let (lhs as Double, rhs as Double):
                return lhs == rhs
            case let (lhs as String, rhs as String):
                return lhs == rhs
            case (let lhs as [String: AnyCodable], let rhs as [String: AnyCodable]):
                return lhs == rhs
            case (let lhs as [AnyCodable], let rhs as [AnyCodable]):
                return lhs == rhs
            default:
                return false
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    var description: String {
        switch value {
            case is Void:
                return String(describing: nil as Any?)
            case let value as CustomStringConvertible:
                return value.description
            default:
                return String(describing: value)
        }
    }
}

extension AnyCodable: CustomDebugStringConvertible {
    var debugDescription: String {
        switch value {
            case let value as CustomDebugStringConvertible:
                return "AnyCodable(\(value.debugDescription))"
            default:
                return "AnyCodable(\(self.description))"
        }
    }
}

extension AnyCodable: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    
    init(nilLiteral: ()) {
        self.init(nil as Any?)
    }
    
    init(booleanLiteral value: Bool) {
        self.init(value)
    }
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
    
    init(floatLiteral value: Double) {
        self.init(value)
    }
    
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
    init(stringLiteral value: String) {
        self.init(value)
    }
    
    init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
    
    init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        self.init(Dictionary<AnyHashable, Any>(elements, uniquingKeysWith: { (first, _) in first }))
    }
}

struct RawCodingKey: CodingKey {
    
    private let string: String
    private let int: Int?
    
    var stringValue: String { return string }
    
    init(string: String) {
        self.string = string
        int = nil
    }
    
    init?(stringValue: String) {
        string = stringValue
        int = nil
    }
    
    var intValue: Int? { return int }
    init?(intValue: Int) {
        string = String(describing: intValue)
        int = intValue
    }
}

extension RawCodingKey: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    
    init(stringLiteral value: String) {
        string = value
        int = nil
    }
    
    init(integerLiteral value: Int) {
        string = ""
        int = value
    }
}
