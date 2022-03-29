//
//  GenreEndpoint.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import Alamofire

enum APIGenreType {
    
    case getCategories
}

extension APIGenreType: APIType {
    
    var service: String {
        return "genre/"
    }
    
    var path: String {
        return "movie/list"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var params: Parameters? {
        return APIConfig.paramAPIKey
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
