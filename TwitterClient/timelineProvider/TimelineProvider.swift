//
//  TimelineProvider.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TimelineProvider<TL: TimelineLoader>: ErrorHandler {
    
    /// 表示されているTimeline
    let timeline = Variable<[Tweet]>([])
    /// 表示されているTimelineの最新tweetId
    let sinceId = Variable<String?>(nil)
    /// 表示されているTimelineの最古tweetId
    let maxId = Variable<String?>(nil)
    /// 通信中かどうか
    let isLoading = Variable<Bool>(false)
    /// 古いタイムラインが存在するかどうか
    let hasPrevious = Variable<Bool>(false)
    
    private let disposeBag = DisposeBag()
    private let loader: TL
    
    init(loader: TL) {
        self.loader = loader
        
        // タイムラインが更新されたらsinceIdを更新する
        timeline
            .asObservable()
            .map { $0.first?.tweetId }
            .bindTo(sinceId)
            .addDisposableTo(disposeBag)
        
        // タイムラインが更新されたらmaxIdを更新する
        timeline
            .asObservable()
            .map { $0.last?.tweetId }
            .bindTo(maxId)
            .addDisposableTo(disposeBag)
        
        // maxIDに変更が無ければ以降タイムラインは存在しない
        Observable
            .zip(maxId.asObservable(), maxId.asObservable().skip(1)) {
                return ($0 == nil) || ($0 != $1)
            }
            .bindTo(hasPrevious)
            .addDisposableTo(disposeBag)
        
        timeline
            .asObservable()
            .map { _ in false }
            .bindTo(isLoading)
            .addDisposableTo(disposeBag)
    }
    
    /// タイムラインの先頭に最新のタイムラインを追加する
    func prependNextTimeline() {
        // 通信中ならreturn
        if isLoading.value == true {
            return
        }
        
        isLoading.value = true

        loader.loadTimeline(sinceId: sinceId.value, maxId: nil)
            .catchError({ [weak self] error in
                self?.handle(error)
                return Observable.just([])
            })
            .map { [weak self] next in
                var tweets: [Tweet] = []
                
                tweets += next
                if let current = self?.timeline.value {
                    tweets += current
                }
                
                return tweets
            }
            .bindTo(timeline)
            .addDisposableTo(disposeBag)
        
    }
    
    /// タイムラインの末尾に古いタイムラインを挿入する
    func appendPreviousTimeline() {
        // 通信中またはもうタイムラインが存在しないならreturn
        if isLoading.value || !hasPrevious.value {
            return
        }
        
        isLoading.value = true
        
        loader.loadTimeline(sinceId: nil, maxId: maxId.value)
            .catchError({ [weak self] error in
                self?.handle(error)
                return Observable.just([])
            })
            .map { [weak self] previous in
                var tweets: [Tweet] = []
                
                if let current = self?.timeline.value {
                    tweets += current
                }
                tweets += previous.dropFirst()
                
                return tweets
            }
            .bindTo(timeline)
            .addDisposableTo(disposeBag)
    }
    
    func reset() {
        timeline.value = []
    }
}

extension TimelineProvider {
    func errorMessage(_ error: Error) -> String {
        switch error {
        case APIError.unauthorized:
            return "認証に失敗しました。\nホーム画面の設定アプリから、Twitterアカウントを確認してもう一度お試しください。"
        case APIError.tooManyRequest:
            return "アクセス制限に達したため、一時的に制限されています。\nしばらくしてからもう一度お試しください。"
        default:
            return "ツイートの取得に失敗しました。\nしばらくしてからもう一度お試しください。"
        }
    }
}
