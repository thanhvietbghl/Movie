//
//  CategoryCollectionViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import Foundation
import RxSwift
import RxRelay

protocol CategoryCollectionViewCellViewModelType {
    
    var categorySelected: BehaviorRelay<Category?> { get }
    var category: Category { get }
    var didTapCategory: PublishSubject<Category> { get set }
    var categoryButtonFont: UIFont { get }
    var categoryButtonHighlightFont: UIFont { get }
}

class CategoryCollectionViewCellViewModel: CategoryCollectionViewCellViewModelType {
    
    var categorySelected: BehaviorRelay<Category?>
    var didTapCategory: PublishSubject<Category>
    var category: Category
    
    var categoryButtonFont = AppFont.getFont(fontName: .regular, fontSize: 12)
    var categoryButtonHighlightFont = AppFont.getFont(fontName: .semiBold, fontSize: 12)
    
    init(categorySelected: BehaviorRelay<Category?>, category: Category, didTapCategory: PublishSubject<Category>) {
        self.category = category
        self.categorySelected = categorySelected
        self.didTapCategory = didTapCategory
    }
}
