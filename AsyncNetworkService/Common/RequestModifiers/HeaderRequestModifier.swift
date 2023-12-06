import Foundation

public class HeaderRequestModifier: NetworkRequestModifier {
    
    private let key: String
    private let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public func mutate(_ request: URLRequest) -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue(value, forHTTPHeaderField: key)
        return mutableRequest
    }
}
