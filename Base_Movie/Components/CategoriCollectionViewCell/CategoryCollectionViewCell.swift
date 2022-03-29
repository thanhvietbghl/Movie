//
//  CateforieCollectionViewCell.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var categoryButton: UIButton!
    @IBOutlet private weak var categoryView: UIView!
    
    private var viewModel: CategoryCollectionViewCellViewModelType?
     
    func setup(viewModel: CategoryCollectionViewCellViewModel, categoryButtonFont: UIFont, categoryButtonHighlightFont: UIFont) {
        self.viewModel = viewModel
        categoryButton.titleLabel?.numberOfLines = 1
        categoryButton.setTitle(viewModel.genreModel?.name, for: .normal)
        categoryView.backgroundColor = viewModel.isSelectedCategory ? AppColors.greenColor : AppColors.lightGrayColor
        categoryButton.setTitleColor(viewModel.isSelectedCategory ? AppColors.grayColor : AppColors.whiteColor, for: .normal)
        categoryButton.titleLabel?.font = viewModel.isSelectedCategory ? categoryButtonHighlightFont : categoryButtonFont
    }

    @IBAction private func CategoryAction(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        viewModel.diTapcategory?()
    }
}
