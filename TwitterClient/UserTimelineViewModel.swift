//
//  UserTimelineViewModel.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/06.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Accounts

class UserTimelineViewModel {
    
    /// 表示されているユーザー
    let user: User!
    /// 新しいTimelineを取得する
    let prependNextTimeline = PublishSubject<Void>()
    /// 古いTimelineを取得する
    let appendPreviousTimeline = PublishSubject<Void>()
    /// 更新中かどうか
    let isLoading: Observable<Bool>
    /// 表示されているタイムライン
    let timeline: Observable<[Tweet]>
    
    /// タイムラインプロバイダー
    private let timelineProvider = Variable<TimelineProvider<UserTimelineLoader>?>(nil)
    
    private let disposeBag = DisposeBag()
    
    init(user: User) {
        self.user = user
        
        isLoading = timelineProvider
            .asObservable()
            .flatMapLatest({ provider -> Observable<Bool> in
                guard let provider = provider else {
                    return Observable.never()
                }
                return provider.isLoading.asObservable()
            })
        
        timeline = timelineProvider
            .asObservable()
            .flatMapLatest({ provider -> Observable<[Tweet]> in
                guard let provider = provider else {
                    return Observable.create {
                        $0.onNext([])
                        return Disposables.create()
                    }
                }
                return provider.timeline.asObservable()
            })
        
        // アカウントがが変わったらアイテムプロバイダーを作り直す
        AccountProvider.shared.account
            .asObservable()
            .distinctUntilChanged({ (currentKey, key)  in
                // アカウントが変更されていなければタイムラインの取得は行わない
                guard let identifier = currentKey?.identifier else {
                    return false
                }
                return identifier == key?.identifier
            })
            .map({ account -> TimelineProvider<UserTimelineLoader>? in
                guard let account = account else {
                    return nil
                }
                let loader = UserTimelineLoader(account: account, user: user)
                return TimelineProvider(loader: loader)
            })
            .bindTo(timelineProvider)
            .addDisposableTo(disposeBag)
        
        timelineProvider
            .asObservable()
            .subscribe(onNext: { $0?.prependNextTimeline() })
            .addDisposableTo(disposeBag)
        
        prependNextTimeline
            .asObservable()
            .withLatestFrom(timelineProvider.asObservable())
            .subscribe(onNext: { $0?.prependNextTimeline() })
            .addDisposableTo(disposeBag)
        
        appendPreviousTimeline
            .asObservable()
            .withLatestFrom(timelineProvider.asObservable())
            .subscribe(onNext: { $0?.appendPreviousTimeline() })
            .addDisposableTo(disposeBag)
    }
}
