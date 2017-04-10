//
//  TweetCell.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/06.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TweetCell: UITableViewCell {
    /// プロフィール画像
    @IBOutlet weak var profileImageView: UIImageView!
    
    /// スクリーンネーム
    @IBOutlet weak var screenNameLabel: UILabel!
    
    /// 名前
    @IBOutlet weak var nameLabel: UILabel!
    
    /// 本文
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    
    var imageDisposable: Disposable?
    let disposeBag = DisposeBag()
    var tweet: Tweet! {
        didSet {
            // スクリーンネーム
            screenNameLabel.text = tweet.user.screenName
            // 名前
            nameLabel.text = "@" + tweet.user.name
            // 本文
            tweetTextLabel.text = tweet.text
            // プロフィール画像
            profileImageView.image = nil
            imageDisposable?.dispose()
            if let profileImageURL = tweet.user.profileImageURL {
                imageDisposable = UIImage.loadImage(url: profileImageURL as URL)
                    .subscribe(onNext: {
                        guard let image = $0 else {
                            return
                        }
                        self.profileImageView.image = image
                    })
                imageDisposable?.addDisposableTo(disposeBag)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 3
    }
}
