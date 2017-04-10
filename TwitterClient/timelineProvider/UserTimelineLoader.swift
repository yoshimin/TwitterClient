//
//  UserTimelineLoader.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxSwift
import Accounts

class UserTimelineLoader: BaseTimelineLoader {
    var user: User
    
    init(account: ACAccount, user: User) {
        self.user = user
        super.init(account: account)
    }
    
    override func loadTimeline(sinceId: String? = nil, maxId: String? = nil) -> Observable<[Tweet]> {
        return UserTimelineAPIClient.loadTimeline(account: account, sinceId: sinceId, maxId: maxId, user: user)
    }
}
