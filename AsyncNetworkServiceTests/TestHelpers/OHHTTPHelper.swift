
import AsyncNetworkService
import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift

// convenience helpers for stubbing data
let everything: (URLRequest) -> (Bool) = { _ in true }
let timeout: DispatchTimeInterval = .seconds(2)

func testWithStub(response: HTTPStubsResponse, test: @escaping (@escaping () -> Void) -> Void) {
    stub(condition: everything) { _ in response }
    test {
        HTTPStubs.removeAllStubs()
    }
}

func stubValidData(data: Data = Data(), statusCode: Int32 = 200, test: @escaping (@escaping () -> Void) -> Void) {
    testWithStub(response: HTTPStubsResponse(data: data, statusCode: statusCode, headers: nil), test: test)
}

func stubValidData(data: Data = Data(), response: HTTPStubsResponse? = nil) {
    if let response = response {
        stub(condition: everything) { _ in response }
    } else {
        stub(condition: everything) { _ in HTTPStubsResponse(data: data, statusCode: 200, headers: nil) }
    }
}

func stubValidJSON(_ json: Any) {
    let JSONData = try! JSONSerialization.data(withJSONObject: json, options: [])
    let stubResponse = HTTPStubsResponse(data: JSONData, statusCode: 200, headers: nil)
    stubValidData(response: stubResponse)
}

func stubString(_ string: String = "some") {
    let data = string.data(using: .utf8)!
    let stubResponse = HTTPStubsResponse(data: data, statusCode: 200, headers: nil)
    stubValidData(response: stubResponse)
}

func stubInvalidJSON() {
    let fakeData = "This is not JSON".data(using: .utf8)!
    let stubResponse = HTTPStubsResponse(data: fakeData, statusCode: 200, headers: nil)
    stubValidData(response: stubResponse)
}

func stubError(_ error: Error = NetworkError.invalidResponseFormat) {
    stubValidData(response: HTTPStubsResponse(error: error))
}

func removeAllStubs() {
    HTTPStubs.removeAllStubs()
}
