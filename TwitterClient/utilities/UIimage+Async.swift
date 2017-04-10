//
//  UIimage+Async.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/07.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UIImage {
    class func loadImage(url: URL) -> Observable<UIImage?> {
        return Observable.create { observer -> Disposable in
            DispatchQueue.global(qos: .default).async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = data, let image = UIImage(data: imageData) {
                        observer.onNext(image)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
