//
//  CategoryRepositories.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import RxSwift

protocol CategoryRepositories {
    func getCategories() -> Observable<CategoriesResponse>
}

class CategoryRepositoriesDefault: CategoryRepositories {
    
    private let apiProvider = APIProvider<CategoryAPIs>()
    
    func getCategories() -> Observable<CategoriesResponse> {
        return apiProvider.request(.getCategories)
    }
}
