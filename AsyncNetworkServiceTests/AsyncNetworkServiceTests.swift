//
//  AsyncNetworkServiceTests.swift
//  AsyncNetworkServiceTests
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import XCTest
import OHHTTPStubs

@testable import AsyncNetworkService

class AsyncNetworkServiceTests: XCTestCase {

    struct TestContext {
        let subject: AsyncHTTPNetworkService
        let mockModifiers: [NetworkRequestModifierMock]!

        init() {
            mockModifiers = [NetworkRequestModifierMock(), NetworkRequestModifierMock()]
            mockModifiers.forEach { mockModifier in
                mockModifier.mutateReturnValue = .stub()
            }
            subject = AsyncHTTPNetworkService(requestModifiers: mockModifiers)
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
        let result = try await testContext.subject.requestData(URL.stub(), validators: [passingValidatorMock])
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
            _ = try await testContext.subject.requestData(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)])
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
            _ = try await testContext.subject.requestData(URL.stub(), validators: [
                passingValidatorMock,
                passingValidatorMock,
                failingValidatorMock(error: NetworkError.noDataInResponse),
                passingValidatorMock
            ])
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
            let _ : CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
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
            let _ : CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
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
            let _ : CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
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
            let _ : CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
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
            let _ : CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [])
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
            let _ : CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)])
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
            let _ : CodableMock = try await testContext.subject.requestObject(URL.stub(), validators: [
                passingValidatorMock,
                passingValidatorMock,
                failingValidatorMock(error: NetworkError.noDataInResponse),
                passingValidatorMock
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
            let _ : [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
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
            let _ : [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
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
            let _ : [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
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
            let _ : [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
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
            let _ : [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [])
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
            let _ : [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)])
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
            let _ : [CodableMock] = try await testContext.subject.requestObjects(URL.stub(), validators: [
                passingValidatorMock,
                passingValidatorMock,
                failingValidatorMock(error: NetworkError.noDataInResponse),
                passingValidatorMock
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
            let _ : String = try await testContext.subject.requestString(URL.stub(), validators: [failingValidatorMock(error: NetworkError.noDataInResponse)])
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
            let _ : String = try await testContext.subject.requestString(URL.stub(), validators: [
                passingValidatorMock,
                passingValidatorMock,
                failingValidatorMock(error: NetworkError.noDataInResponse),
                passingValidatorMock
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
    
}
