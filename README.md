# AsyncHTTPNetworkService

AsyncHTTPNetworkService is a Swift native library network layer for using Concurrency (Async/Await).

The goal is to provide a simple network library so you don't have to think about it. 


### Example use

```swift
let networkService = AsyncHTTPNetworkService()
// see below on URLRequestBuilder + URLRequest extension for a easy example creating URL Requests
let urlRequest = URLRequest(...)
let person: Person = try await networkService.requestObject(urlRequest)
// person inherits from Codable

let searchResults: [Results] = try await networkService.requestObjects(urlRequest)

// networkService.requestVoid
// networkService.requestString

```

# Compatibility

AsyncHTTPNetworkService is compatible to iOS 13+. If there are issues surrounding Aync/Await for < iOS 15, please let us know. 

# URLRequestBuilder + URLRequest extension

AsyncHTTPNetworkService includes `URLRequest` helpers for ease of creating requests and modifying requests 

```swift
let baseURL = URLRequestBuilder(baseURL:  URL(string: "someendpoint"))

baseURL.get("user").queryItems(["tag": "check"])
baseURL.post("login").token("accessToken")
baseURL.post("withBody").body(json: codableObject)
```

# Request Modifiers

AsyncNetworkService provides a basic protocol called `NetworkRequestModifier` that allows you to modify the network request before it sends. 

2 options are included in AsyncNetworkService

## APIKeyRequestModifier
Use this to pass up an `api_key` parameter inside a queryItem for all requests. A good example is when you're using a service that requires an api key. 

This modifier could easily be updated to add an `api_key` to the request headers instead

## BearerTokenRequestModifier

For each request, this will add in the passed in `authenticationToken` inside the `Authorization` header.


# Example App

Included in this repo is a SwiftUI example app using AsyncHTTPNetworkService connecting to a Giphy api. Included is showing how using Codable to decode to objects easily. 

The network calls to connect to Giphy is layed out in [AsyncService.swift](https://github.com/RobotsAndPencils/AsyncHTTPNetworkService/blob/main/AsyncNetworkServiceExample/AsyncService.swift)

Inside the `GiphyService` class is a list of Routes that are connected, and a function for each endpoint that is connected. 

The init of the `GiphyService` includes an `APIKeyRequestModifier` that adds the a `api_key` to the header on each network request.

## Maintainers

[![](https://github.com/mattkiazyk.png?size=50)](https://github.com/mattkiazyk) Matt Kiazyk


## Contact

<a href="http://www.robotsandpencils.com"><img src="R&PLogo.png" width="153" height="74" /></a>

Made with ❤️ by [Robots & Pencils](http://www.robotsandpencils.com)

[Twitter](https://twitter.com/robotsNpencils) | [GitHub](https://github.com/robotsandpencils)
