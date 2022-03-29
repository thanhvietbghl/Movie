//
//  ReviesCollectionViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 26/03/2022.
//

import Foundation

protocol ReviewsCollectionViewCellViewModelType {
    
    var listReviews: [Review] { get }
}

class ReviewsCollectionViewCellViewModel: ReviewsCollectionViewCellViewModelType {
    
    var listReviews = [Review]()

    init(listRevies: [Review]) {
        self.listReviews = listRevies
    }
}
