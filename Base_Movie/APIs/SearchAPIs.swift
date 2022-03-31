//
//  SearchEndpoint.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import Alamofire

enum SearchAPIs {
    case searchMovie(_ input: String, _ page: Int)
}

extension SearchAPIs: APIType {
    
    var service: String {
        return "search/"
    }
    
    var path: String {
        return "movie"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var params: Parameters? {
        switch self {
        case .searchMovie(let input, let page):
            var param = APIConfig.paramAPIKey
            param["query"] = input
            param["page"] = String(page)
            return param
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
