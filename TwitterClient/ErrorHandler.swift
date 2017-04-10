//
//  ErrorHandler.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/09.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ErrorHandler {
    /// エラーのハンドリングを行う
    func handle(_ error: Error)
    
    /// エラーメッセージを返す
    func errorMessage(_ error: Error) -> String
    
    /// エラーダイアログを表示する
    func showError(message: String)
}

extension ErrorHandler {
    func handle(_ error: Error) {
        showError(message: errorMessage(error))
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: message)
            SVProgressHUD.dismiss(withDelay: 2)
        }
    }
}
