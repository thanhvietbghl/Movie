//
//  MovieEndpoint.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import Alamofire

enum MovieAPIs {
    case getMovies(_ page: Int)
    case getMovieDetail(_ movieID: String)
    case getReviews(_ movieID: String)
}

extension MovieAPIs: APIType {
    
    var service: String {
        return "movie/"
    }
    
    var path: String {
        switch self {
        case .getMovies(_):
            return "popular"
        case .getMovieDetail(let movieID):
            return movieID
        case .getReviews(let movieID):
            return "\(movieID)/reviews"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var params: Parameters? {
        switch self {
        case .getMovies(let page):
            var params = APIConfig.paramAPIKey
            params["page"] = String(page)
            return params
        case .getMovieDetail(_):
            return APIConfig.paramAPIKey
        case .getReviews(_):
            return APIConfig.paramAPIKey
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
