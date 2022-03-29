//
//  GenreRepositories.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import RxSwift

protocol GenreRepositories {
    func getCategories() -> Observable<CategoriesResponse>
}

class GenreRepositoriesDefault: GenreRepositories {
    
    private let apiProvider = APIProvider<APIGenreType>()
    
    func getCategories() -> Observable<CategoriesResponse> {
        return apiProvider.request(.getCategories)
    }
}
