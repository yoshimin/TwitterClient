//
//  Tweet.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/04.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import Himotoki

public struct Tweet {
    let tweetId: String
    let user: User
    let text: String
}

extension Tweet: Decodable {
    public static func decode(_ e: Extractor) throws -> Tweet {
        return try Tweet (
            tweetId: e <| "id_str",
            user: e <| "user",
            text: e <| "text"
        )
    }
}
