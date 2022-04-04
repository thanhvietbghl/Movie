//
//  MovieTableViewCell.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var realeaseDateLabel: UILabel!
    @IBOutlet private weak var averageRatingLabel: UILabel!
    @IBOutlet private weak var rateLabe: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var starButton: UIButton!
    
    private var viewModel: MovieTableViewCellViewModelType!
    
    func setup(viewModel: MovieTableViewCellViewModelType) {
        self.viewModel = viewModel
        setupUI()
    }
    
    private func setupUI() {
        posterImageView.setImage(url: viewModel?.movie.getPosterURL(), placeHolder: AppConfig.defaultImage)
        titleLabel.text = viewModel?.movie.title
        realeaseDateLabel.text = viewModel?.movie.releaseDate
        averageRatingLabel.text = String(viewModel?.movie.voteAverage ?? 0)
        rateLabe.text = String(viewModel?.movie.voteCount ?? 0)
        likeButton.setImage(AppImages.getImage(imageName: (viewModel?.movie.isLike ?? false) ? .iconLikeSelected : .iconLike), for: .normal)
        starButton.setImage(AppImages.getImage(imageName: (viewModel?.movie.isLike ?? false) ? .iconStarSelected : .iconStar), for: .normal)
        rateLabe.textColor = (viewModel?.movie.isLike ?? false) ? AppColors.greenColor : AppColors.whiteColor
    }
    
    @IBAction private func didTapLike(_ sender: Any) {
        viewModel.didTapLike.onNext(viewModel.movie)
    }
}
