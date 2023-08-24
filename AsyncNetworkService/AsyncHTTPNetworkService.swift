//
//  AsyncNetworkService.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

/// A  protocol used for `AsyncHTTPNetworkService` that speaks to a remote resource via URL requests
public protocol AsyncNetworkService: AnyObject {
    /// If this is set, all network requests made through this service will have the modifier applied.
    /// To apply multiple mutations to each network request, use `CompositeNetworkRequestModifier`.
    var requestModifiers: [NetworkRequestModifier] { get set }

    /// if this is set, all network requests returned with an error will loop through the list.
    var errorHandlers: [AsyncNetworkErrorHandler] { get set }
    
    /// if this is set, all network reponses returned with success will call `handle` on these interceptors
    var responseInterceptors: [NetworkResponseInterceptor] { get set }

    /// Requests data. This function handles setting up the network request, etc. All subsequent functions build off of this one.
    /// This is the only function that really  needs to  be implemented to provide a new instance of a network service.
    func requestData(_ request: ConvertsToURLRequest, validators: [ResponseValidator]) async throws -> (Data, URLResponse)
}

public class AsyncHTTPNetworkService: AsyncNetworkService {
    public var requestModifiers: [NetworkRequestModifier]
    public var responseInterceptors: [NetworkResponseInterceptor]

    private let urlSession: URLSession

    public var errorHandlers: [AsyncNetworkErrorHandler] = []

    public init(
        requestModifiers: [NetworkRequestModifier] = [],
        errorHandlers: [AsyncNetworkErrorHandler] = [],
        reponseInterceptors: [NetworkResponseInterceptor] = [],
        urlSessionConfiguration: URLSessionConfiguration = .ephemeral
    ) {
        self.requestModifiers = requestModifiers
        self.errorHandlers = errorHandlers
        self.responseInterceptors = reponseInterceptors
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }

    private func applyModifiers(to request: ConvertsToURLRequest) -> URLRequest {
        requestModifiers.reduce(request.asURLRequest()) { previousRequest, modifier in
            modifier.mutate(previousRequest)
        }
    }

    func safeRequest<T>(requestBuilder: @escaping () async throws -> T) async throws -> T {
        do {
            return try await requestBuilder()
        } catch {
            guard let errorHandler = errorHandlers.filter({ $0.canHandle(error) }).first else {
                throw error
            }

            do {
                try await errorHandler.handle(error)
                return try await requestBuilder()
            } catch {
                throw error
            }
        }
    }

    public func requestData(_ request: ConvertsToURLRequest, validators: [ResponseValidator]) async throws -> (Data, URLResponse) {
        return try await safeRequest {
            let modifiedRequest = self.applyModifiers(to: request)

            let dataTask = Task { () -> (Data?, URLResponse) in
                try await self.urlSession.data(for: modifiedRequest)
            }

            let result = await dataTask.result

            switch result {
            case let .failure(error):
                throw error
            case let .success((data, response)):
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponseFormat
                }

                for validate in validators {
                    do {
                        try validate(response, data)
                    } catch {
                        throw error
                    }
                }

                guard let data = data else {
                    throw NetworkError.noDataInResponse
                }
                
                guard let responseInterceptor = self.responseInterceptors.filter({ $0.shouldHandle(data: data, response: response, request: request) }).first else {
                    return (data, response)
                }
                
                return responseInterceptor.handle(data: data, response: response, request: request)
            }
        }
    }
}

public extension AsyncNetworkService {
    /// Requests a single object. That object must conform to `Decodable`. Will interpret the data received as JSON and attempt to decode the object in question from it.
    func requestObject<ObjectType: Decodable>(_ request: ConvertsToURLRequest, validators: [ResponseValidator] = [responseValidator], jsonDecoder: JSONDecoder = JSONDecoder.networkJSONDecoder) async throws -> ObjectType {
        let requestTask = Task { () -> (Data, URLResponse) in
            try await requestData(request, validators: validators)
        }

        let result = await requestTask.result

        switch result {
        case let .failure(error):
            throw error

        case let .success((data, _)):
            do {
                return try jsonDecoder.decode(ObjectType.self, from: data)
            } catch {
                throw NetworkError.decoding(error: error)
            }
        }
    }

    /// Requests a list of objects. The object in question must conform to `Decodable`. Will interpret the data received as JSON and attempt to decode an array of the object in question from it.
    func requestObjects<ObjectType: Decodable>(_ request: ConvertsToURLRequest, validators: [ResponseValidator] = [responseValidator], jsonDecoder: JSONDecoder = JSONDecoder.networkJSONDecoder) async throws -> [ObjectType] {
        let requestTask = Task { () -> (Data, URLResponse) in
            try await requestData(request, validators: validators)
        }

        let result = await requestTask.result

        switch result {
        case let .failure(error):
            throw error

        case let .success((data, _)):
            do {
                return try jsonDecoder.decode([ObjectType].self, from: data)
            } catch {
                throw NetworkError.decoding(error: error)
            }
        }
    }

    /// Requests a string from a network endpoint.
    func requestString(_ request: ConvertsToURLRequest, encoding: String.Encoding = .utf8, validators: [ResponseValidator] = [responseValidator]) async throws -> String {
        let requestTask = Task { () -> (Data, URLResponse) in
            try await requestData(request, validators: validators)
        }

        let result = await requestTask.result

        switch result {
        case let .failure(error):
            throw error
        case let .success((data, _)):
            guard let string = String(data: data, encoding: encoding) else {
                throw NetworkError.decodingString
            }
            return string
        }
    }

    /// Requests a network endpoint without any return
    func requestVoid(_ request: ConvertsToURLRequest, validators: [ResponseValidator] = [responseValidator]) async throws {
        let requestTask = Task { () -> (Data, URLResponse) in
            try await requestData(request, validators: validators)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            throw error
        case .success:
            // can ignore if successful
            return
        }
    }

    /// Requests a single object. That object must be decodable as a `String`. Will interpret the data received as JSON and attempt to decode the object in question from it.
    func requestStringWithResponse(_ request: ConvertsToURLRequest, encoding: String.Encoding = .utf8, validators: [ResponseValidator] = [responseValidator]) async throws -> (String, URLResponse) {
        let requestTask = Task { () -> (Data, URLResponse) in
            try await requestData(request, validators: validators)
        }
        let result = await requestTask.result
        switch result {
        case let .failure(error):
            throw error
        case let .success((data, response)):
            guard let string = String(data: data, encoding: encoding) else {
                throw NetworkError.decodingString
            }
            return (string, response)
        }
    }
}
