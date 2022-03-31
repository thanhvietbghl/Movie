//
//  ReviewsTableViewCell.swift
//  Base_Movie
//
//  Created by Viet Phan on 26/03/2022.
//

import UIKit

class ReviewsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var rateLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    private var viewModel: ReviewsTableViewCellViewModel?
    
    func setup(viewModel: ReviewsTableViewCellViewModel) {
        avatarImageView.setImage(url: viewModel.review.authorDetails.getAvatarURL(), placeHolder: AppConfig.defaultAvatar)
        rateLabel.text = String(viewModel.review.authorDetails.rating ?? 0)
        nameLabel.text = String(viewModel.review.authorDetails.name)
        contentLabel.text = viewModel.review.content
    }
}
