//
//  AsyncService.swift
//  AsyncNetworkServiceExample
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation
import AsyncNetworkService

// Example of using a Rest API

class GiphyService {
    
    let routes: Routes
    var networkService: AsyncHTTPNetworkService
    
    struct Routes {
        var baseRequestBuilder: URLRequestBuilder { return URLRequestBuilder(baseURL:  URL(string: "https://api.giphy.com/v1")!) }
        
        func getRandomGif() -> URLRequest {
            return baseRequestBuilder.get("gifs/random")
        }
    }
    
    init() {
        self.routes = Routes()
        
        self.networkService = AsyncHTTPNetworkService(requestModifiers: [APIKeyRequestModifier(apiKey: "FitddX5BlIIpURiBMZJRmSDDV8MBEgBf")])
    }
    
    /// Example api call to return a random gif url
    func getRandomGif(tag: String, rating: String = "g") async throws -> URL {
    
        let urlRequest = routes.getRandomGif().queryItems([
            "tag": tag,
            "rating": rating
        ])
        
        let requestTask = Task { () -> GiphyDataWrapper in
            return try await networkService.requestObject(urlRequest)
        }
        
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            print("ERROR LOADING GIF: \(error.localizedDescription)")
            throw error
            
        case .success(let giphy):
            return URL(string: giphy.data.images.downsizedLarge.url)!
        }
        
    }
    
}


