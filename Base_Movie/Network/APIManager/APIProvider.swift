//
//  APIProvider.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import RxSwift

protocol APIProviderType: AnyObject {
    
    associatedtype Target: APIType
    
    var apiManager: APIManager { get }
    
    func request<U>(_ target: Target) -> Observable<U> where U : Decodable
    
}

class APIProvider<Target: APIType>: APIProviderType {

    var apiManager: APIManager
    
    init(apiManager: APIManager = APIManagerDefault()) {
        self.apiManager = apiManager
    }
    
    func request<U>(_ target: Target) -> Observable<U> where U : Decodable{
        return apiManager.request(target)
    }
}
