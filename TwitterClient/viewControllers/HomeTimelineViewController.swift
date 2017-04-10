//
//  HomeTimelineViewController.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/04.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Accounts

class HomeTimelineViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = HomeTimelineViewModel()
    
    @IBOutlet weak var accountSwitchButton: UIButton!
    @IBOutlet weak var tableView: TimelineView!
    @IBOutlet weak var tweetButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        AccountProvider.shared.accounts
            .asObservable()
            .map({ $0.count == 0 })
            .bindTo(accountSwitchButton.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        AccountProvider.shared.account
            .asObservable()
            .map({
                return $0?.username
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] username in
                guard let weakSelf = self, let name = username else {
                    return
                }
                // ユーザー名をナビゲーションバーに表示
                weakSelf.accountSwitchButton.setTitle(name, for: .normal)
                
                let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height:(weakSelf.accountSwitchButton.frame.height))
                let width = weakSelf.accountSwitchButton.sizeThatFits(maxSize).width + weakSelf.accountSwitchButton.titleEdgeInsets.left
                weakSelf.accountSwitchButton.frame.size.width = width
                self?.navigationItem.titleView = weakSelf.accountSwitchButton
            })
            .addDisposableTo(disposeBag)
        
        // ユーザー名がタップされたらアカウント選択のアクションシートを表示する
        accountSwitchButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let weakSelf = self else {
                    return
                }
                let actionSheet = UIAlertController(title: "アカウント", message: nil, preferredStyle: .actionSheet)
                for (_, account) in AccountProvider.shared.accounts.value.enumerated() {
                    let action = UIAlertAction(title: account.username, style: UIAlertActionStyle.default, handler: { _ in
                        AccountProvider.shared.selectAccount(account)
                    })
                    actionSheet.addAction(action)
                }
                
                let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.default, handler: nil)
                actionSheet.addAction(cancel)
                
                actionSheet.popoverPresentationController?.sourceView = weakSelf.view
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: weakSelf.view.frame.width*0.5, y:0, width:0, height:0)
                
                weakSelf.present(actionSheet, animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.timeline
            .asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: "TweetCell", cellType: TweetCell.self)) { (row, element, cell) in
                cell.tweet = element
            }
            .addDisposableTo(disposeBag)
        
        // セルがタップされたらユーザー画面を表示する
        tableView.rx
            .modelSelected(Tweet.self)
            .subscribe(onNext: {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                self.showUserTimeline(user: $0.user)
            })
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
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bindTo(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .addDisposableTo(disposeBag)
        
        // 通信中はリフレッシュコントロールを無効にする
        viewModel.isLoading
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ !$0 }
            .bindTo(tableView.refreshingControl.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        tweetButtonItem.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.showPostTweetView()
            })
            .disposed(by: disposeBag)
    }
    
    private func showUserTimeline(user: User) {
        let viewController = UIStoryboard(name: "UserTimeline", bundle: nil).instantiateViewController(withIdentifier: "UserTimeline") as! UserTimelineViewController
        viewController.viewModel = UserTimelineViewModel(user: user)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showPostTweetView() {
        let viewController = UIStoryboard(name: "PostTweet", bundle: nil).instantiateViewController(withIdentifier: "PostTweetNavigation")
        present(viewController, animated: true, completion: nil)
    }
}
