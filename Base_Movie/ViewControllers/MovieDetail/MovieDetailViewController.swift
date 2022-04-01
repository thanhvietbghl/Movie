//
//  MovieDetailViewController.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import UIKit

class MovieDetailViewController: UIViewController, BindableType {

    @IBOutlet private weak var backdropImageView: UIImageView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var overviewView: UIView!
    @IBOutlet private weak var reviewsView: UIView!
    @IBOutlet private weak var contentCollectionView: UICollectionView!
    @IBOutlet private weak var likeView: UIView!
    @IBOutlet private weak var likeImageView: UIImageView!
    
    var viewModel: MovieDetailViewModelType!
    var coodinator: MovieDetailCoodinatorType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupData()
    }
    
    private func setupUI() {
        backdropImageView.setImage(url: viewModel.movie.getBackdropURL(), placeHolder: AppConfig.defaultImage)
        posterImageView.setImage(url: viewModel.movie.getPosterURL(), placeHolder: AppConfig.defaultImage)
        titleLabel.text = viewModel.movie.title
        overviewView.isHidden = viewModel.movieDetailContentType != .aboutMovie
        reviewsView.isHidden = viewModel.movieDetailContentType != .reviews
        likeImageView.image = AppImages.getImage(imageName: .iconWatchList)?.withRenderingMode(.alwaysTemplate)
        updateLikeView()
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
    
    private func setupData() {
        viewModel.getMovieReviews { [weak self] in
            guard let self = self else { return }
            self.contentCollectionView.reloadData()
        }
    }
    
    private func updateUIWithContentView(movieDetailContentType: MovieDetailContentType) {
        guard movieDetailContentType != viewModel.movieDetailContentType else { return }
        viewModel.movieDetailContentType = movieDetailContentType
        overviewView.isHidden = movieDetailContentType != .aboutMovie
        reviewsView.isHidden = movieDetailContentType != .reviews
        contentCollectionView.scrollToItem(at: IndexPath(row: movieDetailContentType.rawValue, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func updateLikeView() {
        likeView.backgroundColor = viewModel.movie.isLike ? AppColors.greenColor : AppColors.lightGrayColor
        likeImageView.tintColor = viewModel.movie.isLike ? AppColors.grayColor : AppColors.whiteColor
    }
    
    @IBAction private func didTapBack(_ sender: Any) {
        coodinator.finish()
    }
    
    @IBAction private func didTapAboutMovie(_ sender: Any) {
        updateUIWithContentView(movieDetailContentType: .aboutMovie)
    }
    
    @IBAction private func didTapReviews(_ sender: Any) {
        updateUIWithContentView(movieDetailContentType: .reviews)
    }
    
    @IBAction private func didTapLike(_ sender: Any) {
        viewModel.didTapLike(self) { [weak self] in
            guard let self = self else { return }
            self.updateLikeView()
        }
    }
}

extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == categoryCollectionView ? viewModel.categories.count : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == categoryCollectionView ? 12 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            return createCategoryCollectionViewCell(collectionView: collectionView, indexPath: indexPath)
        } else {
            if indexPath.row == MovieDetailContentType.aboutMovie.rawValue {
                return createAboutMovieCollectionViewCell(collectionView: collectionView, indexPath: indexPath)
            } else {
                return createReviewsCollectionViewCell(collectionView: collectionView, indexPath: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            let width = viewModel.getWidthOfCategoryItem(indexPath: indexPath)
            return CGSize(width: width, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = contentCollectionView.contentOffset
        visibleRect.size = contentCollectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = contentCollectionView.indexPathForItem(at: visiblePoint) else { return }
        updateUIWithContentView(movieDetailContentType: MovieDetailContentType(rawValue: indexPath.row) ?? .aboutMovie)
    }
    
    private func createCategoryCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < viewModel.categories.count else { return UICollectionViewCell() }
        let cellViewModel = CategoryCollectionViewCellViewModel(
            isSelectedCategory: viewModel.isCategorySeleted(categoryID: viewModel.categories[indexPath.row].id),
            category: viewModel.categories[indexPath.row],
            diTapcategory: { [weak self] in
                guard let self = self else { return }
                self.hanldeDidTapcategory(index: indexPath.row)
            })
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell
        cell?.setup(viewModelType: cellViewModel, categoryButtonFont: viewModel.categoryNameFont, categoryButtonHighlightFont: viewModel.categoryNameHighlightFont)
        return cell ?? UICollectionViewCell()
    }
    
    private func createAboutMovieCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = AboutMovieCollectionViewCellViewModel(movie: viewModel.movie)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AboutMovieCollectionViewCell.identifier, for: indexPath) as? AboutMovieCollectionViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
    
    private func createReviewsCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = ReviewsCollectionViewCellViewModel(reviews: viewModel.reviews)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewsCollectionViewCell.identifier, for: indexPath) as? ReviewsCollectionViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
    
    private func hanldeDidTapcategory(index: Int) {
        let oldCatelorySelectedID = viewModel.categorySelected?.id
        let newCatelorySelected = viewModel.categories[index]
        viewModel.categorySelected = newCatelorySelected
        if let indexOldCatelorySelectedID = viewModel.categories
            .firstIndex(where: { $0.id == oldCatelorySelectedID }) {
            categoryCollectionView.reloadItems(at: [IndexPath(row: indexOldCatelorySelectedID, section: 0)])
        }
        guard let indexNewCatelorySelected = viewModel.categories
            .firstIndex(where: { $0.id == newCatelorySelected.id }) else { return }
        categoryCollectionView.reloadItems(at: [IndexPath(row: indexNewCatelorySelected, section: 0)])
    }
}
