//
//  GiphyData.swift
//  AsyncNetworkServiceExample
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import Foundation

struct GiphyDataWrapper: Decodable {
    let data: GiphyData
}

struct GiphyData: Decodable {
    let images: GiphyImages
}

struct GiphyImages: Decodable {
    let downsizedLarge: GiphyImageData

    enum CodingKeys: String, CodingKey {
        case downsizedLarge = "downsized_large"
    }
}

struct GiphyImageData: Decodable {
    let url: String
}
