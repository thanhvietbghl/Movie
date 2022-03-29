//
//  HomeCoodinator.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import Foundation
import UIKit

protocol HomeCoodinatorType {
    
    func showMovieDetail(movie: Movie, listGenres: [Category], delegate: MovieDetailViewModelDelegate)
}

final class HomeCoodinator: HomeCoodinatorType {
    
    private var window: UIWindow? = nil
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func showMovieDetail(movie: Movie, listGenres: [Category], delegate: MovieDetailViewModelDelegate) {
        guard let roootNavigation = window?.rootViewController as? UINavigationController else {
            return
        }
        let movieDetailCoodinator = MovieDetailCoodinator(navigation: roootNavigation)
        let movieDetailVM = MovieDetailViewModel(movie: movie, listGenres: listGenres, delegate: delegate)
        let movieDetailVC = MovieDetailViewController()
        movieDetailVC.bind(to: movieDetailVM, to: movieDetailCoodinator)
        roootNavigation.pushViewController(movieDetailVC, animated: true)
    }
}
