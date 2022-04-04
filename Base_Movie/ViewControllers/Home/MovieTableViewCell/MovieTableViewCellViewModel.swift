//
//  MovieTableViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import RxSwift

protocol MovieTableViewCellViewModelType {
    
    var movie: Movie { get }
    var didTapLike: PublishSubject<Movie> { get set }
}

class MovieTableViewCellViewModel: MovieTableViewCellViewModelType {
    
    var movie: Movie
    var didTapLike: PublishSubject<Movie>
    
    init(movie: Movie, didTapLike: PublishSubject<Movie>) {
        self.movie = movie
        self.didTapLike = didTapLike
    }
}
