//
//  CateforieCollectionViewCell.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit
import RxSwift

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var categoryButton: UIButton!
    @IBOutlet private weak var categoryView: UIView!
    
    private var viewModelType: CategoryCollectionViewCellViewModelType!
    let disposeBag = DisposeBag()
    
    func setup(viewModelType: CategoryCollectionViewCellViewModelType) {
        self.viewModelType = viewModelType
        categoryButton.titleLabel?.numberOfLines = 1
        categoryButton.setTitle(viewModelType.category.name, for: .normal)
        viewModelType
            .categorySelected
            .subscribe(onNext: { [weak self] categorySelected in
                guard let self = self else { return }
                let isSelectedCategory = viewModelType.category.id == categorySelected?.id
                self.categoryView.backgroundColor = isSelectedCategory ? AppColors.greenColor : AppColors.lightGrayColor
                self.categoryButton.setTitleColor(isSelectedCategory ? AppColors.grayColor : AppColors.whiteColor, for: .normal)
                self.categoryButton.titleLabel?.font = isSelectedCategory ? viewModelType.categoryButtonHighlightFont : viewModelType.categoryButtonFont
            }).disposed(by: disposeBag)
    }

    @IBAction private func CategoryAction(_ sender: Any) {
        viewModelType.didTapCategory.onNext(viewModelType.category)
    }
}
