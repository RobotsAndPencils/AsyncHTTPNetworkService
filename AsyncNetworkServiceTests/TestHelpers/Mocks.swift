import Foundation
@testable import AsyncNetworkService

typealias JSONDictionary = [String: Any]
typealias JSONArray = [JSONDictionary]

final class NetworkRequestModifierMock: NetworkRequestModifier {
    
    public init() {}
    
    // MARK: - mutate
    public var mutateCallCount = 0
    public var mutateReceivedRequest: URLRequest?
    public var mutateReturnValue: URLRequest!
    public func mutate(_ request: URLRequest) -> URLRequest {
        mutateCallCount += 1
        mutateReceivedRequest = request
        return mutateReturnValue
    }
}
extension String: Error {}

let passingValidatorMock: ResponseValidator = { response, data in
    // throw no error
}

func failingValidatorMock(error: Error = NetworkError.invalidResponseFormat) -> ResponseValidator {
    return { response, data in
        throw error
    }
}

struct CodableMock: Codable {
    var someValue: String
        
    static let validJSON: JSONDictionary = [ "someValue": "la la" ]
    static let jsonWithWrongKeys: JSONDictionary = [ "wrongKey": "la la" ]
    static let jsonWithWrongTypes: JSONDictionary = [ "wrongKey": 2 ]
}
