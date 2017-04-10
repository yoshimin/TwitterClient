//
//  TimelineLoader.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxSwift
import Accounts

public protocol TimelineLoader {
    /// タイムライン取得処理
    func loadTimeline(sinceId: String?, maxId: String?) -> Observable<[Tweet]>
}
