//
//  HomeTimelineAPIClient.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/05.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

// @see https://dev.twitter.com/rest/reference/get/statuses/home_timeline

import Foundation
import RxCocoa
import RxSwift
import Accounts

struct HomeTimelineAPIClient {
    static func loadTimeline(account: ACAccount, sinceId: String? = nil, maxId: String? = nil) -> Observable<[Tweet]> {
        var request = HomeTimelineRequest()
        request.sinceId = sinceId
        request.maxId  = maxId
        return request.perform(account: account)
    }
}
