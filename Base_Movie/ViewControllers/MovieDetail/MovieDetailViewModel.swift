//
//  MoviDetailViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import RxSwift
import UIKit

enum MovieDetailContentType: Int {
    case aboutMovie = 0
    case reviews
}

protocol MovieDetailViewModelDelegate: AnyObject {
    func didTapLike(_ viewController: MovieDetailViewController, movieID: Int, islike: Bool, voteCount: Int)
}

protocol MovieDetailViewModelType {
    var categoryNameFont: UIFont { get }
    var categoryNameHighlightFont: UIFont { get }
    var movie: Movie { get }
    var categories: [Category] { get }
    var reviews: [Review] { get }
    var contentType: MovieDetailContentType { get set }
    var categorySelected: Category? { get set }
    
    func isCategorySeleted(categoryID: Int) -> Bool
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat
    func getMovieReviews(completed: @escaping () -> ())
    func didTapLike(_ viewController: MovieDetailViewController, completed: @escaping () -> ())
}

final class MovieDetailViewModel: MovieDetailViewModelType {
    
    private weak var delegate: MovieDetailViewModelDelegate?
    
    var categoryNameFont = AppFont.getFont(fontName: .regular, fontSize: 12)
    var categoryNameHighlightFont = AppFont.getFont(fontName: .semiBold, fontSize: 12)
    var movie: Movie
    var reviews = [Review]()
    var categories = [Category]()
    var categorySelected: Category?
    var contentType: MovieDetailContentType = .aboutMovie

    private let disposeBag = DisposeBag()
    private let repository: MovieRepositories = MovieRepositoriesDefault()
    
    init(movie: Movie, categorys: [Category], delegate: MovieDetailViewModelDelegate?) {
        self.movie = movie
        self.categories = categorys
        self.delegate = delegate
    }
    
    func isCategorySeleted(categoryID: Int) -> Bool {
        return categorySelected?.id == categoryID
    }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < categories.count else { return 0 }
        let isCategorySelected = self.categorySelected?.id == categories[indexPath.row].id
        let fontAttributes = [NSAttributedString.Key.font: isCategorySelected ? categoryNameHighlightFont : categoryNameFont]
        let widthOfName: CGFloat = (categories[indexPath.row].name as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any]).width
        let widthOfSpaceLeftRightName = CGFloat(44)
        return widthOfName + widthOfSpaceLeftRightName
    }
    
    func getMovieReviews(completed: @escaping () -> ()) {
        repository.getReviews(String(movie.id))
            .subscribe { [weak self] reviews in
                guard let self = self else { return }
                self.reviews = reviews.reviews
                completed()
            } onError: { error in
                print(error)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func didTapLike(_ viewController: MovieDetailViewController, completed: @escaping () -> ()) {
        movie.isLike = !movie.isLike
        movie.isLike ? (movie.voteCount += 1) : (movie.voteCount -= 1)
        delegate?.didTapLike(viewController, movieID: movie.id, islike: movie.isLike, voteCount: movie.voteCount)
        completed()
    }
}
