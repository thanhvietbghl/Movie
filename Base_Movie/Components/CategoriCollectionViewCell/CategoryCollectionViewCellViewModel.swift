//
//  CategoryCollectionViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import Foundation

protocol CategoryCollectionViewCellViewModelType {
    
    var isSelectedCategory: Bool { get }
    var genreModel: Category? { get }
    var diTapcategory: (() -> Void)? { get set }
}

class CategoryCollectionViewCellViewModel: CategoryCollectionViewCellViewModelType {
        
    var isSelectedCategory: Bool = false
    var genreModel: Category?
    var diTapcategory: (() -> Void)?
    
    init(isSelectedCategory: Bool, genreModel: Category?, diTapcategory: @escaping (() -> Void)) {
        self.diTapcategory = diTapcategory
        self.genreModel = genreModel
        self.isSelectedCategory = isSelectedCategory
    }
}
