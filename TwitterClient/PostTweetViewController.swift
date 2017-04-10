//
//  PostTweetViewController.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PostTweetViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var postButtonItem: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    let viewModel = PostTweetViewModel()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        textView.becomeFirstResponder()
        
        viewModel.updated
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] tweet in
                if tweet == nil {
                    self?.textView.becomeFirstResponder()
                    return
                }
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        // テキストビューの文字列が投稿可能のときのみ投稿ボタンを有効にする
        viewModel.textValid
            .bindTo(postButtonItem.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        // ナビゲーションバーのpromptに残り文字数を表示する
        viewModel.promptText
            .subscribe(onNext: { [weak self] prompt in
                self?.navigationItem.prompt = prompt
            })
            .addDisposableTo(disposeBag)
        
        textView.rx
        .text
            .bindTo(viewModel.text)
            .addDisposableTo(disposeBag)
        
        // キーボードが表示されたらテキストビューのサイズを変更する
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
            .map({ notification -> CGFloat in
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    return keyboardSize.height
                }
                return 0
            })
            .bindTo(textViewBottom.rx.constant)
            .addDisposableTo(disposeBag)
        
        // キャンセルボタンが押されたら画面を閉じる
        cancelButtonItem.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        // 投稿ボタンが押されたら投稿を行う
        postButtonItem.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.textView.resignFirstResponder()
                self?.viewModel.update.onNext(self?.textView.text)
            })
            .addDisposableTo(disposeBag)
    }
    
}
