//
//  UserTimelineAPIClient.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/05.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

// @see https://dev.twitter.com/rest/reference/get/statuses/user_timeline

import Foundation
import RxCocoa
import RxSwift
import Accounts

struct UserTimelineAPIClient {
    static func loadTimeline(account: ACAccount, sinceId: String? = nil, maxId: String? = nil, user: User) -> Observable<[Tweet]> {
        var request = UserTimelineRequest()
        request.user = user
        request.sinceId = sinceId
        request.maxId  = maxId
        return request.perform(account: account)
    }
}
