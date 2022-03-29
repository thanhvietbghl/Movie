//
//  AboutMovieCollectionViewCellViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 26/03/2022.
//

import Foundation

protocol AboutMovieCollectionViewCellViewModelType {
    
    var movie: Movie { get }
}

class AboutMovieCollectionViewCellViewModel: AboutMovieCollectionViewCellViewModelType {
    
    var movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
}
