//
//  MovieDetailViewController.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import UIKit
import RxCocoa
import RxSwift

class MovieDetailViewController: BaseViewController, BindableType {

    @IBOutlet private weak var backdropImageView: UIImageView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var overviewBottomTitleView: UIView!
    @IBOutlet private weak var reviewsBottomTitleView: UIView!
    @IBOutlet private weak var contentCollectionView: UICollectionView!
    @IBOutlet private weak var likeView: UIView!
    @IBOutlet private weak var likeImageView: UIImageView!
    
    var viewModel: MovieDetailViewModelType!
    var coodinator: MovieDetailCoodinatorType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bind()
        setupUI()
    }
    
    private func setupUI() {
        backdropImageView.setImage(url: viewModel.movie.value.getBackdropURL(), placeHolder: AppConfig.defaultImage)
        posterImageView.setImage(url: viewModel.movie.value.getPosterURL(), placeHolder: AppConfig.defaultImage)
        titleLabel.text = viewModel.movie.value.title
        viewModel.movieDetailContentType.accept(.aboutMovie)
    }
    
    private func bind() {
        
        viewModel.isHiddenOverviewBottomTitleView
            .asDriver(onErrorJustReturn: true)
            .drive(overviewBottomTitleView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isHiddenrReviewsBottomTitleView
            .asDriver(onErrorJustReturn: true)
            .drive(reviewsBottomTitleView.rx.isHidden)
            .disposed(by: disposeBag)
        
        
        viewModel.scrollToIndexPathOfContentViewCollectionView
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.contentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.likeViewBackground
            .asDriver()
            .drive(likeView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        viewModel.likeImageViewImage
            .asDriver()
            .drive(likeImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.showError
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                self.showAlertWithMessage(message: error)
            }).disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        categoryCollectionView.registerCell(ofType: CategoryCollectionViewCell.self)
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        contentCollectionView.registerCell(ofType: AboutMovieCollectionViewCell.self)
        contentCollectionView.registerCell(ofType: ReviewsCollectionViewCell.self)
        contentCollectionView.dataSource = self
        contentCollectionView.delegate = self
    }
    
    @IBAction private func didTapBack(_ sender: Any) {
        coodinator.finish()
    }
    
    @IBAction private func didTapAboutMovie(_ sender: Any) {
        viewModel.didTapContentType.onNext(.aboutMovie)
    }
    
    @IBAction private func didTapReviews(_ sender: Any) {
        viewModel.didTapContentType.onNext(.reviews)

    }
    
    @IBAction private func didTapLike(_ sender: Any) {
        viewModel.didTapLike.onNext((self))
    }
}

extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfItemsInCollectionViewSection(categoryCollectionView: categoryCollectionView, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.getMinimumLineSpacingForSectionOfCollectionViewSection(categoryCollectionView: categoryCollectionView, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewModel.createCollectionViewCell(categoryCollectionView: categoryCollectionView, collectionView: collectionView, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.getSizeForItemOfCollectionView(categoryCollectionView: categoryCollectionView, collectionView: collectionView, indexPath: indexPath)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.scrollViewDidEndDecelerating(contentCollectionView: contentCollectionView)
    }
}
