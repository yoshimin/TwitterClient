//
//  User.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/04.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import Himotoki

struct User {
    let screenName: String
    let name: String
    let profileImageURL: URL?
    let profileBackgroundImageUrl: URL?
    let userDescription: String
}

extension User: Decodable {
    static func decode(_ e: Extractor) throws -> User {
        let URLTransformer = Transformer<String, URL> { URLString throws -> URL in
            if let url = URL(string: URLString) {
                return url
            }
            
            throw customError("Invalid URL string: \(URLString)")
        }
        
        let imageURL = try? URLTransformer.apply(e <| "profile_image_url_https")
        let backgroundImageUrl = try? URLTransformer.apply(e <| "profile_background_image_url_https")
        
        return try User (
            screenName: e <| "screen_name",
            name: e <| "name",
            profileImageURL: imageURL,
            profileBackgroundImageUrl: backgroundImageUrl,
            userDescription: e <| "description"
        )
    }
}
