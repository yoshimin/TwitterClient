//
//  UserTimelineRequest.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/06.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import Social
import Himotoki

struct UserTimelineRequest : TwitterRequest {
    typealias Response = [Tweet]
    
    var user: User!
    
    var sinceId: String?
    
    var maxId: String?
    
    var url: URL {
        return URL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")!
    }
    
    var method: SLRequestMethod {
        return .GET
    }
    
    var parameters: [AnyHashable : Any]? {
        var parameters: [AnyHashable : Any] = [:]
        if let sinceId = sinceId {
            parameters["since_id"] = sinceId
        }
        if let maxId = maxId {
            parameters["max_id"] = maxId
        }
        parameters["screen_name"] = user.screenName
        return parameters
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) -> [Tweet] {
        guard let tweets = try? [Tweet].decode(object) else {
            return []
        }
        return tweets
    }
}
