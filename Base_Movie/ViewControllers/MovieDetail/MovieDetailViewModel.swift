//
//  MoviDetailViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import RxSwift
import UIKit
import RxRelay

enum MovieDetailContentType: Int {
    case aboutMovie = 0
    case reviews
}

protocol MovieDetailViewModelDelegate: AnyObject {
    func didTapLike(_ viewController: MovieDetailViewController, movie: Movie)
}

protocol MovieDetailViewModelType {
    var categoryNameFont: UIFont { get }
    var categoryNameHighlightFont: UIFont { get }
    var movie: BehaviorRelay<Movie> { get }
    var categories: [Category] { get }
    var reviews: BehaviorRelay<[Review]> { get }
    var didTapContentType: PublishSubject<MovieDetailContentType> { get set }
    var didTapLike: PublishSubject<MovieDetailViewController> { get set }
    var movieDetailContentType: BehaviorRelay<MovieDetailContentType> { get set }
    var categorySelected: BehaviorRelay<Category?> { get }
    var isHiddenOverviewBottomTitleView: PublishSubject<Bool> { get }
    var isHiddenrReviewsBottomTitleView: PublishSubject<Bool> { get }
    var likeViewBackground: BehaviorRelay<UIColor> { get }
    var likeImageViewImage: BehaviorRelay<UIImage> { get }
    
    var didTapCategory: PublishSubject<Category> { get set }
    var showError: PublishSubject<String> { get }
    var tableViewReloadData: PublishSubject<Void> { get }
    var scrollToIndexPathOfContentViewCollectionView: PublishSubject<IndexPath> { get }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat
    func getNumberOfItemsInCollectionViewSection(categoryCollectionView: UICollectionView, collectionView: UICollectionView) -> Int
    func getMinimumLineSpacingForSectionOfCollectionViewSection(categoryCollectionView: UICollectionView, collectionView: UICollectionView) -> CGFloat
    func getSizeForItemOfCollectionView(categoryCollectionView: UICollectionView, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
    func createCollectionViewCell(categoryCollectionView: UICollectionView, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func scrollViewDidEndDecelerating(contentCollectionView: UICollectionView)
}

final class MovieDetailViewModel: MovieDetailViewModelType {
    
    private let disposebag = DisposeBag()
    private weak var delegate: MovieDetailViewModelDelegate?
    
    var categoryNameFont = AppFont.getFont(fontName: .regular, fontSize: 12)
    var categoryNameHighlightFont = AppFont.getFont(fontName: .semiBold, fontSize: 12)
    
    var movie: BehaviorRelay<Movie>
    var reviews = BehaviorRelay<[Review]>(value: [])
    var categories = [Category]()
    var likeViewBackground = BehaviorRelay<UIColor>(value: AppColors.greenColor)
    var likeImageViewImage = BehaviorRelay<UIImage>(value: UIImage())
    var categorySelected = BehaviorRelay<Category?>(value: nil)
    var didTapContentType = PublishSubject<MovieDetailContentType>()
    var didTapLike = PublishSubject<MovieDetailViewController>()
    var movieDetailContentType = BehaviorRelay<MovieDetailContentType>(value: .aboutMovie)
    var didTapCategory = PublishSubject<Category>()
    var showError = PublishSubject<String>()
    var tableViewReloadData = PublishSubject<Void>()
    var isHiddenOverviewBottomTitleView = PublishSubject<Bool>()
    var isHiddenrReviewsBottomTitleView = PublishSubject<Bool>()
    var scrollToIndexPathOfContentViewCollectionView = PublishSubject<IndexPath>()
    var scrollViewDidEndDecelerating = PublishSubject<Void>()

    private let disposeBag = DisposeBag()
    private let repository: MovieRepositories = MovieRepositoriesDefault()
    
    init(movie: Movie, categorys: [Category], delegate: MovieDetailViewModelDelegate) {
        self.movie = BehaviorRelay<Movie>(value: movie)
        self.categories = categorys
        
        movieDetailContentType.subscribe(onNext: { [weak self] type in
            guard let self = self else { return }
            self.isHiddenOverviewBottomTitleView.onNext(type != .aboutMovie)
            self.isHiddenrReviewsBottomTitleView.onNext(type != .reviews)
            }).disposed(by: disposeBag)
        
        self.movie.subscribe(onNext: { [weak self] movie in
            guard let self = self else { return }
            self.likeViewBackground.accept(movie.isLike ? AppColors.greenColor : AppColors.lightGrayColor)
            self.likeImageViewImage.accept(AppImages.getImage(imageName: movie.isLike ? .iconWatchList : .iconLike) ?? UIImage())
        }).disposed(by: disposeBag)
        
        reviews.subscribe(onNext: { [weak self] review in
            guard let self = self else { return }
            self.tableViewReloadData.onNext(())
        }).disposed(by: disposeBag)
        
        didTapContentType.subscribe(onNext: { [weak self] type in
            guard let self = self, self.movieDetailContentType.value != type else { return }
            self.scrollToIndexPathOfContentViewCollectionView.onNext(IndexPath(row: type.rawValue, section: 0))
            self.movieDetailContentType.accept(type)
        }).disposed(by: disposeBag)
        
        didTapLike.subscribe(onNext: { [weak self] viewController in
            guard let self = self else { return }
            delegate.didTapLike(viewController, movie: self.movie.value)
            var movie = self.movie.value
            movie.isLike = !movie.isLike
            movie.isLike ? (movie.voteCount += 1) : (movie.voteCount -= 1)
            self.movie.accept(movie)
        }).disposed(by: disposeBag)
        
        getMovieReviews(id: String(movie.id))
    }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < categories.count else { return 0 }
        let isCategorySelected = self.categorySelected.value?.id == categories[indexPath.row].id
        let fontAttributes = [NSAttributedString.Key.font: isCategorySelected ? categoryNameHighlightFont : categoryNameFont]
        let widthOfName: CGFloat = (categories[indexPath.row].name as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any]).width
        return widthOfName + AppConfig.widthBetweenLeftRightAndTitleButton
    }
    
    func getMovieReviews(id: String) {
        repository.getReviews(id)
            .map({
                $0.reviews
            })
            .subscribe { [weak self] reviews in
                guard let self = self else { return }
                self.reviews.accept(reviews)
            } onError: { [weak self] error in
                guard let self = self else { return }
                self.showError.onNext(error.localizedDescription)
            }.disposed(by: disposeBag)
    }
}

extension MovieDetailViewModel {
    
    func getNumberOfItemsInCollectionViewSection(categoryCollectionView: UICollectionView, collectionView: UICollectionView) -> Int {
        return collectionView == categoryCollectionView ? categories.count : 2
    }
    
    func getSizeForItemOfCollectionView(categoryCollectionView: UICollectionView, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            let width = getWidthOfCategoryItem(indexPath: indexPath)
            return CGSize(width: width, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func getMinimumLineSpacingForSectionOfCollectionViewSection(categoryCollectionView: UICollectionView, collectionView: UICollectionView) -> CGFloat {
        return collectionView == categoryCollectionView ? 12 : 0
    }
    
    func scrollViewDidEndDecelerating(contentCollectionView: UICollectionView) {
        var visibleRect = CGRect()
        visibleRect.origin = contentCollectionView.contentOffset
        visibleRect.size = contentCollectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = contentCollectionView.indexPathForItem(at: visiblePoint) else { return }
        movieDetailContentType.accept(MovieDetailContentType(rawValue: indexPath.row) ?? .aboutMovie)
    }

    func createCollectionViewCell(categoryCollectionView: UICollectionView, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
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
    
    private func createCategoryCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < categories.count else { return UICollectionViewCell() }
        let cellViewModel = CategoryCollectionViewCellViewModel(
            categorySelected: categorySelected,
            category: categories[indexPath.row],
            didTapCategory: didTapCategory)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell
        cell?.setup(viewModelType: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
    
    private func createAboutMovieCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = AboutMovieCollectionViewCellViewModel(movie: movie.value)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AboutMovieCollectionViewCell.identifier, for: indexPath) as? AboutMovieCollectionViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
    
    private func createReviewsCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = ReviewsCollectionViewCellViewModel(reviews: reviews.value)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewsCollectionViewCell.identifier, for: indexPath) as? ReviewsCollectionViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
}
