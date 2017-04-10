//
//  BaseTimelineLoader.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/11.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxSwift
import Accounts

class BaseTimelineLoader: TimelineLoader {
    let account: ACAccount
    
    init(account: ACAccount) {
        self.account = account
    }
    
    func loadTimeline(sinceId: String?, maxId: String?) -> Observable<[Tweet]> {
        return Observable.just([])
    }
}
