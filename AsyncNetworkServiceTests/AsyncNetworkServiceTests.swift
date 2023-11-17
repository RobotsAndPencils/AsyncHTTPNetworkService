//
//  AsyncNetworkServiceTests.swift
//  AsyncNetworkServiceTests
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import OHHTTPStubs
import XCTest

@testable import AsyncNetworkService

class AsyncNetworkServiceTests: XCTestCase {
    struct TestContext {
        let subject: AsyncHTTPNetworkService
        let mockModifiers: [NetworkRequestModifierMock]!
        let inactiveInterceptor: NetworkReponseInterceptorMock = {
            let mock = NetworkReponseInterceptorMock()
            mock.shouldHandleReturnValue = false
            return mock
        }()
        let modifyingInterceptor: NetworkReponseInterceptorMock = {
            let mock = NetworkReponseInterceptorMock()
            mock.shouldHandleReturnValue = true
            mock.handleReturnValue = (Data.modifiedStub, URLResponse.modifiedStub)
            return mock
        }()

        init() {
            mockModifiers = [NetworkRequestModifierMock(), NetworkRequestModifierMock()]
            mockModifiers.forEach { mockModifier in
                mockModifier.mutateReturnValue = .stub()
            }
            
            subject = AsyncHTTPNetworkService(
                requestModifiers: mockModifiers,
                reponseInterceptors: [],
                shouldLogRequests: false
            )
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        removeAllStubs()
    }

    // MARK: RequestData

    func testRequestDataSuccessfully() async throws {
        let testContext = TestContext()

        stubValidData()

        // it downloads some data
        let result = try await testContext.subject.requestData(URL.stub(), validators: [passingValidatorMock], shouldAddRequestModifiers: true)
        XCTAssertNotNil(result.0)

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestValidatorFailsAndItsTheOnlyOne() async throws {
        let testContext = TestContext()
        stubValidData()
        // it downloads some data
        do {
            _ = try await testContext.subject.requestData(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)], shouldAddRequestModifiers: true)
            throw "I shouldn't call this"
        } catch {
            // reports the error that the validator encountered"
            XCTAssertEqual(error as? NetworkError, NetworkError.noDataInResponse)
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestValidatorFailsAndThereAreAlsoPassingValidators() async throws {
        let testContext = TestContext()
        stubValidData()

        // it downloads some data
        do {
            _ = try await testContext.subject.requestData(
                URL.stub(),
                validators: [
                    passingValidatorMock,
                    passingValidatorMock,
                    failingValidatorMock(error: NetworkError.noDataInResponse),
                    passingValidatorMock,
                ],
                shouldAddRequestModifiers: true)
            throw "I shouldn't call this"
        } catch {
            // reports the error that the validator encountered"
            XCTAssertEqual(error as? NetworkError, NetworkError.noDataInResponse)
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    // MARK: RequestObject

    func testRequestObjectWithValidJSON() async throws {
        let testContext = TestContext()
        stubValidJSON(CodableMock.validJSON)

        // it downloads some data
        do {
            let result: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
            XCTAssertNotNil(result)
        } catch {
            throw "I shouldn't call this"
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectWithWrongKeys() async throws {
        let testContext = TestContext()
        stubValidJSON(CodableMock.jsonWithWrongKeys)

        // it reports an error
        do {
            let _: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectWrongValueType() async throws {
        let testContext = TestContext()
        stubValidJSON(CodableMock.jsonWithWrongTypes)

        // it reports an error
        do {
            let _: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectValildJSONArray() async throws {
        let testContext = TestContext()
        stubValidJSON([CodableMock.validJSON])

        // it reports an error
        do {
            let _: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectWithInvalidJSON() async throws {
        let testContext = TestContext()
        stubInvalidJSON()

        // it reports an error
        do {
            let _: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectWhenErrorEncountered() async throws {
        let testContext = TestContext()
        stubError()

        // it reports an error
        do {
            let _: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectWhenRequestValidatorFailsOne() async throws {
        let testContext = TestContext()
        stubValidJSON(CodableMock.validJSON)

        // it reports an error
        do {
            let _: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectWhenRequestValidatorFailsAndPasses() async throws {
        let testContext = TestContext()
        stubValidJSON(CodableMock.validJSON)

        // it reports an error
        do {
            let _: CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [
                passingValidatorMock,
                passingValidatorMock,
                failingValidatorMock(error: NetworkError.noDataInResponse),
                passingValidatorMock,
            ])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    // MARK: RequestObjects

    func testRequestObjectsWithValidJSON() async throws {
        let testContext = TestContext()
        stubValidJSON([CodableMock.validJSON])

        // it downloads some data
        do {
            let result: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
            XCTAssertNotNil(result)
        } catch {
            throw "I shouldn't call this"
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectsWithValidNonArray() async throws {
        let testContext = TestContext()
        stubValidJSON(CodableMock.validJSON)

        // it reports an error
        do {
            let _: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectsWithWrongKeys() async throws {
        let testContext = TestContext()
        stubValidJSON([CodableMock.jsonWithWrongKeys])

        // it reports an error
        do {
            let _: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectsWrongValueType() async throws {
        let testContext = TestContext()
        stubValidJSON([CodableMock.jsonWithWrongTypes])

        // it reports an error
        do {
            let _: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectsWithInvalidJSON() async throws {
        let testContext = TestContext()
        stubInvalidJSON()

        // it reports an error
        do {
            let _: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decoding = networkError else {
                throw "Error is not a decoding error"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectsWhenErrorEncountered() async throws {
        let testContext = TestContext()
        stubError()

        // it reports an error
        do {
            let _: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectsWhenRequestValidatorFailsOne() async throws {
        let testContext = TestContext()
        stubValidJSON([CodableMock.validJSON])

        // it reports an error
        do {
            let _: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestObjectsWhenRequestValidatorFailsAndPasses() async throws {
        let testContext = TestContext()
        stubValidJSON([CodableMock.validJSON])

        // it reports an error
        do {
            let _: [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [
                passingValidatorMock,
                passingValidatorMock,
                failingValidatorMock(error: NetworkError.noDataInResponse),
                passingValidatorMock,
            ])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    // MARK: requestString

    func testRequestStringWithValidJSON() async throws {
        let testContext = TestContext()
        stubString("Bobs your uncle")

        // it downloads some data
        do {
            let result: String = try await testContext.subject.requestString(URL.stub(), validators: [])
            XCTAssertEqual(result, "Bobs your uncle")
        } catch {
            throw "I shouldn't call this"
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestStringWithNonString() async throws {
        let testContext = TestContext()
        stubValidData(data: UIImage.stub().pngData()!)

        do {
            let _: String = try await testContext.subject.requestString(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .decodingString = networkError else {
                throw "Error is not a decodingString"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestStringWithError() async throws {
        let testContext = TestContext()
        stubError(NetworkError.noDataInResponse)

        do {
            let _: String = try await testContext.subject.requestString(URL.stub(), validators: [])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestStringWhenRequestValidatorFailsOne() async throws {
        let testContext = TestContext()
        stubString("Hola")

        // it reports an error
        do {
            let _: String = try await testContext.subject.requestString(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }

        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }

    func testRequestStringWhenRequestValidatorFailsAndPasses() async throws {
        let testContext = TestContext()
        stubString("Hola")

        // it reports an error
        do {
            let _: String = try await testContext.subject.requestString(URL.stub(), validators: [
                passingValidatorMock,
                passingValidatorMock,
                failingValidatorMock(error: NetworkError.noDataInResponse),
                passingValidatorMock,
            ])
            throw "I shouldn't call this"
        } catch {
            let networkError = error as? NetworkError
            guard case .noDataInResponse = networkError else {
                throw "Error is not a noDataInResponse"
            }
        }
        // runAsyncTest {}
        // it applies modifications
        testContext.mockModifiers.forEach { mockModifier in
            XCTAssertEqual(mockModifier.mutateCallCount, 1)
        }
    }
    
    func testmodifyingInterceptor() async throws {
        let testContext = TestContext()
        testContext.subject.responseInterceptors = [
            testContext.inactiveInterceptor,
            testContext.modifyingInterceptor
        ]
        
        let originalDataToReturn = Data.originalStub
        
        stubValidData(data: originalDataToReturn, response: nil)

        // it downloads some data
        let result = try await testContext.subject.requestData(URL.stub(), validators: [passingValidatorMock], shouldAddRequestModifiers: true)

        // it calls applicable interceptor
        XCTAssertEqual(testContext.inactiveInterceptor.handleCallCount, 0)
        XCTAssertEqual(testContext.modifyingInterceptor.handleCallCount, 1)
        
        // modifying interceptor receives original data
        XCTAssertEqual(originalDataToReturn, testContext.modifyingInterceptor.handleReceivedValue?.data)
        
        // interceptor modifies the response
        XCTAssertEqual(result.0, testContext.modifyingInterceptor.handleReturnValue?.data)
        XCTAssertEqual(String(decoding: result.0, as: UTF8.self), String.modified)
    }
    
    func testPassthroughInterceptor() async throws {
        let testContext = TestContext()
        testContext.subject.responseInterceptors = [
            testContext.inactiveInterceptor
        ]
        
        let originalDataToReturn = Data.originalStub
        
        stubValidData(data: originalDataToReturn, response: nil)

        // it downloads some data
        let result = try await testContext.subject.requestData(URL.stub(), validators: [passingValidatorMock], shouldAddRequestModifiers: true)

        // no interceptors called
        XCTAssertEqual(testContext.inactiveInterceptor.handleCallCount, 0)
        
        // original data returned
        XCTAssertEqual(result.0, originalDataToReturn)
        XCTAssertEqual(String(decoding: result.0, as: UTF8.self), String.original)
    }
    
    
    // MARK: FileUploadRequestModifier

    func testFileUploadRequestModifier() async throws {
        var request = URLRequest(url: URL.stub())
        
        let fileData1 = "mock file data 1".data(using: .utf8)!
        let fileData2 = "mock file data 2".data(using: .utf8)!
        
        // Sample test file mock file data for upload
        let files: [UploadableFile] = [
            // image with no additional data
            .init(data: fileData1, fileName: "file name 1.jpg", fieldName: "images"),
            
            // image with additional data
            .init(data: fileData2,
                  fileName: "file name 2.jpg",
                  fieldName: "images",
                  additionalContent: ["property name1": "property value1", "property name2": "property value2"]),
        ]
        
        request = request.withFiles(files: files, boundary: "CCC574E7-15E1-40BA-B3D3-679F20F3E2EC-29057-00026EB0E2E684C0")
        
        let expectedHeaders = ["Content-Type": "multipart/form-data;boundary=CCC574E7-15E1-40BA-B3D3-679F20F3E2EC-29057-00026EB0E2E684C0"]
        
        let actualHeaders = request.allHTTPHeaderFields
        
        let expectedBodyString = """
\r
--CCC574E7-15E1-40BA-B3D3-679F20F3E2EC-29057-00026EB0E2E684C0\r
Content-Disposition: form-data; name="images"; filename="file name 1.jpg"\r
Content-Type: image/jpeg\r
\r
mock file data 1\r
--CCC574E7-15E1-40BA-B3D3-679F20F3E2EC-29057-00026EB0E2E684C0\r
Content-Disposition: form-data; name="images"; filename="file name 2.jpg"\r
Content-Type: image/jpeg\r
\r
mock file data 2\r
--CCC574E7-15E1-40BA-B3D3-679F20F3E2EC-29057-00026EB0E2E684C0\r
Content-Disposition: form-data; name="property name1"\r
\r
property value1\r
--CCC574E7-15E1-40BA-B3D3-679F20F3E2EC-29057-00026EB0E2E684C0\r
Content-Disposition: form-data; name="property name2"\r
\r
property value2\r
--CCC574E7-15E1-40BA-B3D3-679F20F3E2EC-29057-00026EB0E2E684C0--\r

"""
        
        let actualBodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
        
        
        XCTAssertEqual(actualHeaders, expectedHeaders)
        XCTAssertEqual(actualBodyString, expectedBodyString)
    }
    
    func testMimeTypes() {
        let pngData = UIImage.stub().pngData()!
        XCTAssertEqual(pngData.mimeType, "image/png")
        XCTAssertEqual(pngData.fileExtension, "png")
        
        let jpegData = UIImage.stub().jpegData(compressionQuality: 0)!
        XCTAssertEqual(jpegData.mimeType, "image/jpeg")
        XCTAssertEqual(jpegData.fileExtension, "jpg")
    }
}
