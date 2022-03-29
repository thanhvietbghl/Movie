//
//  SearchRepositories.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import RxSwift

// rename
protocol SearchRepositories {
    
    func searchMovies(input: String, page: Int) -> Observable<MovieResponse>
}

class SearchRepositoriesDefault: SearchRepositories {
    
    private let apiProvider = APIProvider<APISearchType>()
    
    func searchMovies(input: String, page: Int) -> Observable<MovieResponse> {
       return apiProvider.request(.searchMovie(input, page))
    }
}
