//
//  UpdateRequest.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import Social
import Himotoki

struct UpdateRequest: TwitterRequest {
    typealias Response = Tweet?
    
    var text: String!
    
    var url: URL {
        return URL(string: "https://api.twitter.com/1.1/statuses/update.json")!
    }
    
    var method: SLRequestMethod {
        return .POST
    }
    
    var parameters: [AnyHashable : Any]? {
        return ["status": text]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) -> Tweet? {
        return try? decodeValue(object)
    }
}
