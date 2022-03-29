//
//  SearchRepositories.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import RxSwift

protocol SearchRepositories {
    func searchMovies(input: String, page: Int) -> Observable<MovieResponse>
}

class SearchRepositoriesDefault: SearchRepositories {
    
    private let apiProvider = APIProvider<SearchAPIs>()
    
    func searchMovies(input: String, page: Int) -> Observable<MovieResponse> {
       return apiProvider.request(.searchMovie(input, page))
    }
}
