//
//  APIEndpoint.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import Alamofire

protocol APIType {
    var service: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var params: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var encoding: ParameterEncoding { get }
    var fullPath: String { get }
    var isPublic: Bool { get }
}

extension APIType {
    
    var fullPath: String {
        return APIConfig.baseURLString + service + path
    }
    
    var isPublic: Bool {
        return false
    }
}
