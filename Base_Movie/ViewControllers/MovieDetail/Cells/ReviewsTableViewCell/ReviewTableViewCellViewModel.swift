//
//  ReviewTableViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 26/03/2022.
//

import Foundation

protocol ReviewsTableViewCellViewModelType {
    
    var review: Review { get }
}

class ReviewsTableViewCellViewModel: ReviewsTableViewCellViewModelType {

    var review: Review
    
    init(review: Review) {
        self.review = review
    }
}
