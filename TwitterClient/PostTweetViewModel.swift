//
//  PostTweetViewModel.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/10.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Accounts
import twitter_text
import SVProgressHUD

class PostTweetViewModel: ErrorHandler {
    private static let maxTweetLength = 140
    
    let update = PublishSubject<String?>()
    var updated: Observable<Tweet?>!
    let text = PublishSubject<String?>()
    let textValid: Observable<Bool>
    let promptText: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init() {
        // 残り文字列計算
        // @see https://github.com/twitter/twitter-text/tree/master/objc
        promptText = text
            .map({
                var length = PostTweetViewModel.maxTweetLength
                if let text = $0 {
                    length -= Int(TwitterText.tweetLength(text))
                }
                return "残り " + "\(length)"
            })
        
        // 投稿ボタンのenable/disableを判定
        textValid = text
            .map({
                guard let text = $0, !text.isEmpty, Int(TwitterText.tweetLength(text)) <= PostTweetViewModel.maxTweetLength else {
                    return false
                }
                return true
            })
        
        updated = update
            .flatMapLatest { text -> Observable<Tweet?> in
                guard let account = AccountProvider.shared.account.value, let text = text else {
                    return Observable.just(nil)
                }
                return UpdateAPIClient.update(account: account, text: text)
                    .catchError({ [weak self] error in
                        self?.handle(error)
                        return Observable.just(nil)
                    })
        }
        .shareReplay(1)
        
        update
            .asObservable()
            .subscribe(onNext: { _ in
                SVProgressHUD.show()
            })
            .addDisposableTo(disposeBag)
        
        updated
            .filter({ $0 != nil })
            .subscribe(onNext: { _ in
                SVProgressHUD.dismiss()
            })
            .addDisposableTo(disposeBag)
    }
}

extension PostTweetViewModel {
    func errorMessage(_ error: Error) -> String {
        switch error {
        case APIError.unauthorized:
            return "認証に失敗しました。\nホーム画面の設定アプリから、Twitterアカウントを確認してもう一度お試しください。"
        case APIError.tooManyRequest:
            return "アクセス制限に達したため、一時的に制限されています。\nしばらくしてからもう一度お試しください。"
        default:
            return "ツイートの投稿に失敗しました。\n内容を確認してもう一度お試しください。"
        }
    }
}
