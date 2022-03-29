//
//  MovieTableViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation

protocol MovieTableViewCellViewModelType {
    
    var movie: Movie { get set }
    func changeLike()
}

class MovieTableViewCellViewModel: MovieTableViewCellViewModelType {
    
    var movie: Movie
    var didTapLike: ((_ isLike: Bool, _ voteCount: Int) -> Void)?
    
    init(movie: Movie, didTapLike: @escaping ((_ isLike: Bool, _ voteCount: Int) -> Void)) {
        self.movie = movie
        self.didTapLike = didTapLike
    }
    
    func changeLike() {
        movie.isLike = !movie.isLike
        movie.isLike ? (movie.voteCount += 1) : (movie.voteCount -= 1)
        didTapLike?(movie.isLike, movie.voteCount)
    }
}
