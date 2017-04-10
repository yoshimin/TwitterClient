//
//  UserTimelineViewController.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/04.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UserTimelineViewController: UIViewController {
    let disposeBag = DisposeBag()
    var viewModel: UserTimelineViewModel!
    
    var profileView: UserProfileView!
    @IBOutlet weak var tableView: TimelineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        title = viewModel.user.name
        
        // テーブルヘッダービューにユーザープロフィールを表示
        let nib = UINib(nibName: "UserProfileView", bundle: Bundle.main)
        profileView = nib.instantiate(withOwner: self, options: nil).first as! UserProfileView
        profileView.user = viewModel.user
        
        tableView.tableHeaderView = profileView
        
        viewModel.timeline
            .asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: "TweetCell", cellType: TweetCell.self)) { (row, element, cell) in
                cell.selectionStyle = .none
                cell.tweet = element
            }
            .addDisposableTo(disposeBag)
        
        // 一番下までスクロールしたら古いツイートを読み込む
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { [weak self] (cell, indexPath) in
                guard let weakSelf = self else {
                    return
                }
                if indexPath.row == weakSelf.tableView.numberOfRows(inSection: indexPath.section) - 1 {
                    self?.viewModel.appendPreviousTimeline.onNext()
                }
            })
            .addDisposableTo(disposeBag)
        
        // プルダウンで新着を取得
        tableView.refreshingControl.rx
            .controlEvent(.valueChanged)
            .subscribe( onNext: { [weak self] isLoading in
                self?.viewModel.prependNextTimeline.onNext()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.prependNextTimeline
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.refreshingControl.endRefreshing()
            })
            .addDisposableTo(disposeBag)
        
        // 通信中はインジケータを回す
        viewModel.isLoading
            .observeOn(MainScheduler.instance)
            .bindTo(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .addDisposableTo(disposeBag)
        
        // 通信中はリフレッシュコントロールを無効にする
        viewModel.isLoading
            .observeOn(MainScheduler.instance)
            .map{ !$0 }
            .bindTo(tableView.refreshingControl.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // テーブルヘッダーの高さを動的に変更する
        if let headerView = tableView.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()

            headerView.frame.size.height = profileView.descriptionView.frame.maxY + 12
            
            tableView.tableHeaderView = headerView
        }
    }
    
}

