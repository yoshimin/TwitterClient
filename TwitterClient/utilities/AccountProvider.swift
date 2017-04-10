//
//  AccountProvider.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/04.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Accounts

enum AccountError: Error {
    case denied
    case noAccount
    case systemError
}

final class AccountProvider: ErrorHandler {
    
    static let shared: AccountProvider = AccountProvider()
    
    let disposeBag = DisposeBag()
    
    /// 選択可能なアカウント一覧
    let accounts = Variable<[ACAccount]>([])
    /// 選択されたアカウント
    var account = Variable<ACAccount?>(nil)
    
    private init() {
        // 保存されたアカウントと選択可能なアカウントの一覧から使用するアカウントを決定する
        accounts
            .asObservable()
            .map { accounts -> ACAccount? in
                // アカウントが保存されている場合
                if let id = AccountIdStore.getStoredAccountId() {
                    // 保存されたアカウントが存在する場合はそのアカウントを使用
                    if let ac = accounts.filter({ $0.identifier.isEqual(to: id)}).first {
                        return ac
                    }
                }
                // 保存されたのアカウントが削除されていた場合、またはアカウントが未選択の場合は先頭のアカウントを採用
                return accounts.first
            }
            .bindTo(account)
            .addDisposableTo(disposeBag)
        
        // アカウントが選択されたらそのIDを保存しておく
        account
            .asObservable()
            .subscribe(onNext: {
                guard let accountId = $0?.identifier else {
                    return
                }
                // アカウントが変更されたらIDを保存する
                AccountIdStore.saveAccountId(accountId as String)
            })
            .addDisposableTo(disposeBag)
    }
    
    /// アカウントを選択する
    func selectAccount(_ ac: ACAccount) {
        account.value = ac
    }
    
    /// 端末に登録されているアカウント一覧を取得する
    func fetchAccounts() {
        fetch()
            .bindTo(accounts)
            .addDisposableTo(disposeBag)
    }
    
    private func fetch() -> Observable<[ACAccount]> {
        return Observable.create { observer -> Disposable in
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
            
            accountStore.requestAccessToAccounts(with: accountType, options: nil) { (authorized, error) -> Void in
                DispatchQueue.main.sync {
                    // アカウントの取得に失敗した場合
                    if error != nil {
                        self.handle(AccountError.systemError)
                        
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }
                    
                    // アクセス権がない場合
                    if (!authorized) {
                        self.handle(AccountError.denied)
                        
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }
                    
                    // アカウントが登録されていない場合
                    guard let storedAccounts = accountStore.accounts(with: accountType), storedAccounts.count > 0 else {
                        self.handle(AccountError.noAccount)
                        
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }
                    
                    // アカウントが取得できた場合
                    observer.onNext(storedAccounts as! [ACAccount])
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}

extension AccountProvider {
    func errorMessage(_ error: Error) -> String {
        switch error {
        case AccountError.denied:
            return "アカウントの取得に失敗しました。\nホーム画面の設定アプリから、Twitterアカウントへのアクセスを許可してください。"
        case AccountError.noAccount:
            return "アカウントの取得に失敗しました。\nホーム画面の設定アプリから、Twitterアカウントを設定してください。"
        default:
            return "アカウントの取得に失敗しました。\nホーム画面の設定アプリから、Twitterアカウントを確認してもう一度お試しください。"
        }
    }
}
