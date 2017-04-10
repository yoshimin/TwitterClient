//
//  UserProfileView.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/07.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserProfileView: UIView {
    /// プロフィール背景画像
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    
    /// プロフィール画像
    @IBOutlet weak var profileImageView: UIImageView!
    
    /// スクリーンネーム
    @IBOutlet weak var screenNameLabel: UILabel!
    
    /// 名前
    @IBOutlet weak var nameLabel: UILabel!
    
    /// 説明文
    @IBOutlet weak var descriptionView: UITextView!
    
    let disposeBag = DisposeBag()
    var user: User! {
        didSet {
            // スクリーンネーム
            screenNameLabel.text = user.screenName
            // 名前
            nameLabel.text = "@" + user.name
            // 説明文
            descriptionView.text = user.userDescription
            // プロフィール背景画像
            if let profileImageURL = user.profileImageURL {
            UIImage.loadImage(url: profileImageURL as URL)
                .subscribe(onNext: {
                    guard let image = $0 else {
                        return
                    }
                    self.profileImageView.image = image
                })
                .addDisposableTo(disposeBag)
            }
            // プロフィール画像
            if let profileBackgroundImageUrl = user.profileBackgroundImageUrl {
                UIImage.loadImage(url: profileBackgroundImageUrl as URL)
                    .subscribe(onNext: {
                        guard let image = $0 else {
                            return
                        }
                        self.profileBackgroundImageView.image = image
                    })
                    .addDisposableTo(disposeBag)
            }
            
        }
    }
    
    override func awakeFromNib() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 3
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        let color = UIColor(red: 80/255, green: 171/255, blue: 241/255, alpha: 1)
        descriptionView.linkTextAttributes = [NSForegroundColorAttributeName:color]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if descriptionView.text.isEmpty {
            descriptionView.frame.size.height = 0
        } else {
            let maxSize = CGSize(width: descriptionView.frame.width, height:CGFloat.greatestFiniteMagnitude)
            descriptionView.frame.size.height = descriptionView.sizeThatFits(maxSize).height
        }
    }
}
