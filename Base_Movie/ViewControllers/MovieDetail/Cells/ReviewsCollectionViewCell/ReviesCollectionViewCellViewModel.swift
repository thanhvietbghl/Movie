//
//  ReviesCollectionViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 26/03/2022.
//

import Foundation

protocol ReviewsCollectionViewCellViewModelType {
    
    var reviews: [Review] { get }
}

class ReviewsCollectionViewCellViewModel: ReviewsCollectionViewCellViewModelType {
    
    var reviews = [Review]()

    init(reviews: [Review]) {
        self.reviews = reviews
    }
}
