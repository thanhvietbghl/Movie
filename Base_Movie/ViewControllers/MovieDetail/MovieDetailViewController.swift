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
    
    var viewModelType: MovieDetailViewModelType!
    var coodinatorType: MovieDetailCoodinatorType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupData()
    }
    
    private func setupUI() {
        backdropImageView.setImage(url: viewModelType.movie.getBackdropPathImage(), placeHolder: AppConfig.defaultImage)
        posterImageView.setImage(url: viewModelType.movie.getposterPathImage(), placeHolder: AppConfig.defaultImage)
        titleLabel.text = viewModelType.movie.title
        overviewView.isHidden = viewModelType.contentType != .aboutMovie
        reviewsView.isHidden = viewModelType.contentType != .reviews
        likeImageView.image = UIImage(named: "icon_watch_list")?.withRenderingMode(.alwaysTemplate)
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
        viewModelType.getMovieReviews { [weak self] in
            self?.contentCollectionView.reloadData()
        }
    }
    // rename param
    private func updateUIWithContentView(contentType: MovieDetailContentType) {
        guard contentType != viewModelType.contentType else { return }
        viewModelType.contentType = contentType
        overviewView.isHidden = contentType != .aboutMovie
        reviewsView.isHidden = contentType != .reviews
        contentCollectionView.scrollToItem(at: IndexPath(row: contentType.rawValue, section: 0),
                                           at: .centeredHorizontally,
                                           animated: true)
    }
    
    private func updateLikeView() {
        likeView.backgroundColor = viewModelType.movie.isLike ? AppColors.greenColor : AppColors.lightGrayColor
        likeImageView.tintColor = viewModelType.movie.isLike ? AppColors.grayColor : AppColors.whiteColor
    }
    
    @IBAction private func didTapBack(_ sender: Any) {
        coodinatorType.finish()
    }
    
    @IBAction private func didTapAboutMovie(_ sender: Any) {
        updateUIWithContentView(contentType: .aboutMovie)
    }
    
    @IBAction private func didTapReviews(_ sender: Any) {
        updateUIWithContentView(contentType: .reviews)
    }
    
    @IBAction private func didTapLike(_ sender: Any) {
        viewModelType.didTapLike { [weak self] in
            self?.updateLikeView()
        }
    }
}

extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == categoryCollectionView ? viewModelType.listGenres.count : 2
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
            let width = viewModelType.getWidthOfCategoryItem(indexPath: indexPath)
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
        updateUIWithContentView(contentType: MovieDetailContentType(rawValue: indexPath.row) ?? .aboutMovie)
    }
         
    private func createCategoryCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = CategoryCollectionViewCellViewModel(
            isSelectedCategory: viewModelType.isCategorySeleted(categoryID: viewModelType.listGenres[indexPath.row].id),
            genreModel: viewModelType.listGenres[indexPath.row],
            diTapcategory: { [weak self] in
                self?.hanldeDidTapcategory(index: indexPath.row)
            })
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell
        cell?.setup(viewModel: cellViewModel,
                    categoryButtonFont: viewModelType.categoryNameFont,
                    categoryButtonHighlightFont: viewModelType.categoryNameHighlightFont)
        return cell ?? UICollectionViewCell()
    }
    
    private func createAboutMovieCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = AboutMovieCollectionViewCellViewModel(movie: viewModelType.movie)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AboutMovieCollectionViewCell.identifier, for: indexPath) as? AboutMovieCollectionViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
    
    private func createReviewsCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = ReviewsCollectionViewCellViewModel(listRevies: viewModelType.listReviews)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewsCollectionViewCell.identifier, for: indexPath) as? ReviewsCollectionViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
    
    private func hanldeDidTapcategory(index: Int) {
        let oldCatelorySelectedID = viewModelType.categorySelected?.id
        let newCatelorySelected = viewModelType.listGenres[index]
        viewModelType.categorySelected = newCatelorySelected
        if let indexOldCatelorySelectedID = viewModelType.listGenres
            .firstIndex(where: { $0.id == oldCatelorySelectedID }) {
            categoryCollectionView.reloadItems(at: [IndexPath(row: indexOldCatelorySelectedID, section: 0)])
        }
        guard let indexNewCatelorySelected = viewModelType.listGenres
            .firstIndex(where: { $0.id == newCatelorySelected.id }) else { return }
        categoryCollectionView.reloadItems(at: [IndexPath(row: indexNewCatelorySelected, section: 0)])
    }
}
