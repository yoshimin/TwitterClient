//
//  AccountIdStore.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/05.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxSwift
import Accounts

struct AccountIdStore {
    static let storedAccountId: String = "StoredAccountId"
    
    /// アカウントを保存する
    static func saveAccountId(_ identifier: String?) {
        guard let id = identifier else {
            return
        }
        UserDefaults.standard.set(id, forKey: storedAccountId)
        UserDefaults.standard.synchronize()
    }
    
    /// 保存されたアカウントを取得する
    static func getStoredAccountId() -> String? {
        return UserDefaults.standard.object(forKey: storedAccountId) as? String
    }
}
