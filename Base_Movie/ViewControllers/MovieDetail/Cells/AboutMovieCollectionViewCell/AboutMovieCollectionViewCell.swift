//
//  AboutMovieCollectionViewCell.swift
//  Base_Movie
//
//  Created by Viet Phan on 26/03/2022.
//

import UIKit

class AboutMovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var realeaseDateLabel: UILabel!
    @IBOutlet weak var acerageRatingLabel: UILabel!
    @IBOutlet weak var rateCountLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    
    private var viewModel: AboutMovieCollectionViewCellViewModelType?
    
    func setup(viewModel: AboutMovieCollectionViewCellViewModelType) {
        overviewLabel.text = viewModel.movie.overview
        realeaseDateLabel.text = viewModel.movie.releaseDate
        acerageRatingLabel.text = String(viewModel.movie.voteAverage)
        rateCountLabel.text = String(viewModel.movie.voteCount)
        popularityLabel.text = String(viewModel.movie.popularity)
    }
}
