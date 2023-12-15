//
//  URLRequestBuilder.swift
//  AsyncNetworkService
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public enum ContentTypeEnum: String {
    case json = "application/json"
    case urlencoded = "application/x-www-form-urlencoded"
}

/// URLRequestBuilder is a simple "fluent"-style builder for constructing URLRequest objects. This api is
/// intended to make it very simple to define requests with an intuitive one-liner syntax.
///
/// .e.g. let builder = URLRequestBuilder()
///       builder.get("/users/\(id)/profile").request()
///       builder.post("/users").body(json: profile).setValue("1.2.1", forHeader: "X-API-Version")
///
///       let otherBuilder = URLRequestBuilder(Environment.current.someOtherBaseURL)
///       otherBuilder.get("/some/path?param=blah").withCachePolicy(.returnCacheDataElseLoad)
public class URLRequestBuilder {
    internal let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func get(_ requestPath: String, contentType: ContentTypeEnum = .json) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.get).contentType(contentType)
    }

    public func post(_ requestPath: String, contentType: ContentTypeEnum = .json) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.post).contentType(contentType)
    }

    public func put(_ requestPath: String) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.put)
    }

    public func delete(_ requestPath: String) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.delete)
    }
}

public extension URLRequest {
    func path(_ path: String) -> URLRequest {
        var request = self
        request.url = url?.appendingPathComponent(path)
        return request
    }

    func method(_ method: HTTPMethod) -> URLRequest {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }

    func body(json body: Encodable, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601) -> URLRequest {
        var request = self
        request.httpBody = try? body.serializeToJSON(dateEncodingStrategy: dateEncodingStrategy)
        return request.contentType(.json)
    }

    func queryItems(_ items: [String: String]) -> URLRequest {
        var request = self
        guard let url = request.url else { return request }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let urlQueryItems = items.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        components?.append(queryItems: urlQueryItems)

        guard let finalURL = components?.url else { return request }
        request.url = finalURL
        return request
    }

    func queryItems(_ queryItems: [URLQueryItem]) -> URLRequest {
        var request = self
        guard let url = request.url else { return request }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.append(queryItems: queryItems)

        guard let finalURL = components?.url else { return request }
        request.url = finalURL
        return request
    }

    func token(_ token: String) -> URLRequest {
        let bearerRequestModifier = BearerTokenRequestModifier(authenticationToken: token)
        return bearerRequestModifier.mutate(self)
    }

    func contentType(_ contentType: ContentTypeEnum) -> URLRequest {
        return setValue(contentType.rawValue, forHeader: "Content-Type")
    }

    func setValue(_ value: String, forHeader header: String) -> URLRequest {
        var request = self
        request.setValue(value, forHTTPHeaderField: header)
        return request
    }

    func withCachePolicy(_ policy: URLRequest.CachePolicy) -> URLRequest {
        var request = self
        request.cachePolicy = policy
        return request
    }
    
    func withFiles(files: [UploadableFile], boundary: String = ProcessInfo.processInfo.globallyUniqueString) -> URLRequest {
        let modifier = FileUploadRequestModifier(files: files, boundary: boundary)
        return modifier.mutate(self)
    }

    private func newLine() -> Data {
        return Data("\n".utf8)
    }
}

private extension URLComponents {
    mutating func append(queryItems: [URLQueryItem]) {
        guard !queryItems.isEmpty else {
            return
        }
        self.queryItems = (self.queryItems ?? [URLQueryItem]()) + queryItems
    }
}
