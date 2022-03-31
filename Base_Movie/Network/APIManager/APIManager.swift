//
//  APIService.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Alamofire
import RxSwift

protocol APIManager {
    
    func request<U: Decodable>(_ apiProvider: APIType) -> Observable<U>
}

class APIManagerDefault: APIManager {
        
    private let session = Session()
        
    func request<U>(_ apiProvider: APIType) -> Observable<U> where U : Decodable {
        let result = Observable<U>.create { (observer: AnyObserver<U>) -> Disposable in
            print("""
                  API Request ----> \(apiProvider.fullPath)
                  API method ---->  \(apiProvider.method)
                  API param ---->  \(String(describing: apiProvider.params))
                  API Headers ---->  \(String(describing: apiProvider.headers))
                  """)
            let request = self.session.request(apiProvider.fullPath,
                                               method: apiProvider.method,
                                               parameters: apiProvider.params,
                                               encoding: apiProvider.encoding,
                                               headers: apiProvider.headers,
                                               interceptor: nil,
                                               requestModifier: nil)
                .validate(statusCode: 200..<400)
            request.responseDecodable(of: U.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                    case .failure(let error):
                        print(error.localizedDescription)
                        if let apiError: APIError = DecodeUtils.decode(data: response.data) {
                            observer.onError(apiError)
                        } else {
                            observer.onError(APIError.commonError)
                        }
                    }
                    observer.on(.completed)
                }
            return Disposables.create(with: { request.cancel() })
        }
        return result
    }
}
