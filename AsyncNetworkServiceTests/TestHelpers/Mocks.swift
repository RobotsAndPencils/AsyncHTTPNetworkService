@testable import AsyncNetworkService
import Foundation

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

final class NetworkReponseInterceptorMock: NetworkResponseInterceptor {
    
    public var shouldHandleCallCount = 0
    public var shouldHandleReceivedValue: (data: Data, response: URLResponse, request: ConvertsToURLRequest)?
    public var shouldHandleReturnValue: Bool!
    public func shouldHandle(data: Data, response: URLResponse, request: ConvertsToURLRequest) -> Bool {
        shouldHandleCallCount += 1
        shouldHandleReceivedValue = (data, response, request)
        return shouldHandleReturnValue
    }
    
    public var handleCallCount = 0
    public var handleReceivedValue: (data: Data, response: URLResponse, request: ConvertsToURLRequest)?
    public var handleReturnValue: (data: Data, response: URLResponse)?
    public func handle(data: Data, response: URLResponse, request: ConvertsToURLRequest) -> (Data, URLResponse) {
        handleCallCount += 1
        handleReceivedValue = (data, response, request)
        return handleReturnValue ?? (data, response)
    }
    
}

extension String: Error {}

let passingValidatorMock: ResponseValidator = { _, _ in
    // throw no error
}

func failingValidatorMock(error: Error = NetworkError.invalidResponseFormat) -> ResponseValidator {
    return { _, _ in
        throw error
    }
}

struct CodableMock: Codable {
    var someValue: String

    static let validJSON: JSONDictionary = ["someValue": "la la"]
    static let jsonWithWrongKeys: JSONDictionary = ["wrongKey": "la la"]
    static let jsonWithWrongTypes: JSONDictionary = ["wrongKey": 2]
}
