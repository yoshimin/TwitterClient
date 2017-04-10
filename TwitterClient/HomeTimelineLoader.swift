//
//  HomeTimelineLoader.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxSwift
import Accounts

class HomeTimelineLoader: BaseTimelineLoader {
    override func loadTimeline(sinceId: String? = nil, maxId: String? = nil) -> Observable<[Tweet]> {
        return HomeTimelineAPIClient.loadTimeline(account: account, sinceId: sinceId, maxId: maxId)
    }
}
