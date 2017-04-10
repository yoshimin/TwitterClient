//
//  HomeTimelineRequest.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/05.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import Accounts
import Social
import Himotoki

struct HomeTimelineRequest : TwitterRequest {
    typealias Response = [Tweet]
    
    var sinceId: String?
    
    var maxId: String?
    
    var url: URL {
        return URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!
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
        return parameters
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) -> [Tweet] {
        guard let tweets = try? [Tweet].decode(object) else {
            return []
        }
        return tweets
    }
}
