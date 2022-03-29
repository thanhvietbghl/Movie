//
//  MoviDetailViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import RxSwift

enum MovieDetailContentType: Int {
    case aboutMovie = 0
    case reviews
}

protocol MovieDetailViewModelDelegate: AnyObject {
    func didTapLike(movieID: Int, islike: Bool, voteCount: Int)
}
//rename
protocol MovieDetailViewModelType {
    var categoryNameFont: UIFont { get }
    var categoryNameHighlightFont: UIFont { get }
    var movie: Movie { get }
    var listGenres: [Category] { get }
    var listReviews: [Review] { get }
    var contentType: MovieDetailContentType { get set }
    var categorySelected: Category? { get set }
    
    func isCategorySeleted(categoryID: Int) -> Bool
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat
    func getMovieReviews(completed: @escaping () -> ())
    func didTapLike(completed: @escaping () -> ())
}

final class MovieDetailViewModel: MovieDetailViewModelType {
    
    private weak var delegate: MovieDetailViewModelDelegate?
    
    var categoryNameFont = AppFont.getFont(fontNameType: .regular, fontSize: 12)
    var categoryNameHighlightFont = AppFont.getFont(fontNameType: .semiBold, fontSize: 12)
    var movie: Movie
    var listReviews = [Review]()
    var listGenres = [Category]()
    var categorySelected: Category?
    var contentType: MovieDetailContentType = .aboutMovie

    private let disposeBag = DisposeBag()
    private let repository: MovieRepositories = MovieRepositoriesDefault()
    
    init(movie: Movie, listGenres: [Category], delegate: MovieDetailViewModelDelegate?) {
        self.movie = movie
        self.listGenres = listGenres
        self.delegate = delegate
    }
    
    func isCategorySeleted(categoryID: Int) -> Bool {
        return categorySelected?.id == categoryID
    }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < listGenres.count else { return 0 }
        let isCategorySelected = self.categorySelected?.id == listGenres[indexPath.row].id
        let fontAttributes = [NSAttributedString.Key.font: isCategorySelected ? categoryNameHighlightFont : categoryNameFont]
        let widthOfName: CGFloat = (listGenres[indexPath.row].name as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any]).width
        let widthOfSpaceLeftRightName = CGFloat(44)
        return widthOfName + widthOfSpaceLeftRightName
    }
    
    func getMovieReviews(completed: @escaping () -> ()) {
        repository.getReviews(String(movie.id))
            .subscribe { reviews in
                self.listReviews = reviews.reviews
                completed()
            } onError: { error in
                print(error)
            } onCompleted: {
//                completed()
            }.disposed(by: disposeBag)
    }
    
    func didTapLike(completed: @escaping () -> ()) {
        movie.isLike = !movie.isLike
        movie.isLike ? (movie.voteCount += 1) : (movie.voteCount -= 1)
        delegate?.didTapLike(movieID: movie.id, islike: movie.isLike, voteCount: movie.voteCount)
        completed()
    }
}
