//
//  UpdateAPIClient.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

// @see https://dev.twitter.com/rest/reference/post/statuses/update.html

import Foundation
import RxCocoa
import RxSwift
import Accounts

struct UpdateAPIClient {
    static func update(account: ACAccount, text: String) -> Observable<Tweet?> {
        var request = UpdateRequest()
        request.text = text
        return request.perform(account: account)
    }
}
