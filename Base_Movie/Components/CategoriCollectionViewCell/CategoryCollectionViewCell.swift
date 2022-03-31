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
    
    private var viewModelType: CategoryCollectionViewCellViewModelType?
    
    func setup(viewModelType: CategoryCollectionViewCellViewModelType, categoryButtonFont: UIFont, categoryButtonHighlightFont: UIFont) {
        self.viewModelType = viewModelType
        categoryButton.titleLabel?.numberOfLines = 1
        categoryButton.setTitle(viewModelType.category?.name, for: .normal)
        categoryView.backgroundColor = viewModelType.isSelectedCategory ? AppColors.greenColor : AppColors.lightGrayColor
        categoryButton.setTitleColor(viewModelType.isSelectedCategory ? AppColors.grayColor : AppColors.whiteColor, for: .normal)
        categoryButton.titleLabel?.font = viewModelType.isSelectedCategory ? categoryButtonHighlightFont : categoryButtonFont
    }

    @IBAction private func CategoryAction(_ sender: Any) {
        guard let viewModelType = viewModelType else { return }
        viewModelType.diTapcategory?()
    }
}
