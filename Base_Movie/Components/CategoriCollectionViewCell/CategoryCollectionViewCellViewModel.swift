//
//  CategoryCollectionViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import Foundation

protocol CategoryCollectionViewCellViewModelType {
    
    var isSelectedCategory: Bool { get }
    var category: Category? { get }
    var diTapcategory: (() -> Void)? { get set }
}

class CategoryCollectionViewCellViewModel: CategoryCollectionViewCellViewModelType {
        
    var isSelectedCategory: Bool = false
    var category: Category?
    var diTapcategory: (() -> Void)?
    
    init(isSelectedCategory: Bool, category: Category?, diTapcategory: @escaping (() -> Void)) {
        self.diTapcategory = diTapcategory
        self.category = category
        self.isSelectedCategory = isSelectedCategory
    }
}
