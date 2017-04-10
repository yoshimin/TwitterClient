//
//  TwitterRequest.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/05.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import Foundation
import Social
import Accounts
import RxSwift
import RxCocoa

enum APIError: Error {
    case invalidRequest
    case unauthorized
    case forbidden
    case tooManyRequest
    case invalidResponse
    case serverError
}

public protocol TwitterRequest {
    associatedtype Response
    
    /// リクエストURL
    var url: URL { get }
    
    /// HTTPメソッド
    var method: SLRequestMethod { get }
    
    /// パラメーター
    var parameters: [AnyHashable : Any]? { get }
    
    /// リクエストを実行する
    func perform(account: ACAccount) -> Observable<Response>
    
    /// レスポンス
    func response(from object: Any, urlResponse: HTTPURLResponse) -> Response
}

extension TwitterRequest {
    
    var parameters: [AnyHashable : Any]? {
        return nil
    }
    
    func perform(account: ACAccount) -> Observable<Response> {
        return Observable.create({ (observer) -> Disposable in
            let request: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: self.method, url: self.url, parameters: self.parameters)
            request.account = account
            request.perform(handler: { (responseData, urlResponse, error) in
                guard
                    let data = responseData,
                    let res = urlResponse,
                    let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
                        observer.onError(APIError.invalidResponse)
                        return
                }
                
                guard res.statusCode < 400 else {
                    if res.statusCode > 500 {
                        observer.onError(APIError.serverError)
                    }
                    else if res.statusCode == 401 {
                        observer.onError(APIError.unauthorized)
                    }
                    else if res.statusCode == 403 {
                        observer.onError(APIError.forbidden)
                    }
                    else if res.statusCode == 429 {
                        observer.onError(APIError.tooManyRequest)
                    }
                    else {
                        observer.onError(APIError.invalidRequest)
                    }
                    return
                }
                
                let object = self.response(from: jsonObject, urlResponse: res)
                observer.onNext(object)
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}
