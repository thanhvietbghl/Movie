//
//  MovieRepositores.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import RxSwift

protocol MovieRepositories {
    func getMovies(_ page: Int) -> Observable<MovieResponse>
    func getReviews(_ movieID: String) -> Observable<ReviewsResponse>
}

class MovieRepositoriesDefault: MovieRepositories {
    
    private let apiProvider = APIProvider<MovieAPIs>()
    
    func getMovies(_ page: Int) -> Observable<MovieResponse> {
        return apiProvider.request(.getMovies(page))
    }
    
    func getReviews(_ movieID: String) -> Observable<ReviewsResponse> {
        return apiProvider.request(.getReviews(movieID))
    }
}
