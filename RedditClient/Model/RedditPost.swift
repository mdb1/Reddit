//
//  RedditPost.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

struct RedditDataPost: Codable {
    
    let author_fullname: String
    let title: String
    let id: String
    let num_comments: Int
    let preview: PreviewModel?
    let created_utc: Double
    
}

struct RedditPost: Codable {

    let data: RedditDataPost
    
}

struct PreviewModel: Codable {
    let images: [ImageModel]?
    let enabled: Bool
}

struct ImageModel: Codable {
    let source: SourceModel?
    let resolutions: [SourceModel]?
}

struct SourceModel: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct RedditResponse: Codable {
    let data: DataResponse
}

struct DataResponse: Codable {
    let children: [RedditPost]
}

