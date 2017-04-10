//
//  TimelineView.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit

class TimelineView: UITableView {
    let refreshingControl = UIRefreshControl()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // セルの高さを自動計算する
        estimatedRowHeight = 82
        rowHeight = UITableViewAutomaticDimension
        
        // カスタムセルを登録する
        register(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        
        // リフレッシュコントロールをセットする
        addSubview(refreshingControl)
    }
}
