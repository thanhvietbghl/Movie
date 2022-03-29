//
//  HomeViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import Foundation
import RxSwift

protocol HomeViewModelType {
    
    var categoryNameFont: UIFont { get }
    var categoryNameHighlightFont: UIFont { get }
    var movies: [Movie] { get }
    var categories: [Category] { get }
    var isCanLoadMoreMovie: Bool { get }
    var categorySelected: Category? { get set }
    var isSearching: Bool { get }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat
    func getListMovie(isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void)
    func getCategories(completion: @escaping () -> Void)
    func searchMovie(input: String, isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void)
    func didTapLike(index: Int, islike: Bool, voteCount: Int)
    func diTapcategory(completion: @escaping () -> Void)
}

final class HomeViewModel: HomeViewModelType {
    
    var categoryNameFont = AppFont.getFont(fontNameType: .regular, fontSize: 12)
    var categoryNameHighlightFont = AppFont.getFont(fontNameType: .semiBold, fontSize: 12)
    var movies = [Movie]()
    var categories = [Category]()
    var categorySelected: Category?
    var isCanLoadMoreMovie: Bool = true
    var isSearching: Bool = false
    var moviesCurrentPage: Int = 1
    let movieRepositoriy: MovieRepositories = MovieRepositoriesDefault()
    let genreRepositories: GenreRepositories = GenreRepositoriesDefault()
    let searchRepositories: SearchRepositories = SearchRepositoriesDefault()
    
    private let disposeBag = DisposeBag()
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < categories.count else { return 0 }
        let isCategorySelected = self.categorySelected?.id == categories[indexPath.row].id
        let fontAttributes = [NSAttributedString.Key.font: isCategorySelected ? categoryNameHighlightFont : categoryNameFont]
        let widthOfName: CGFloat = (categories[indexPath.row].name as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any]).width
        let widthOfSpaceLeftRightName = CGFloat(44)
        return widthOfName + widthOfSpaceLeftRightName
    }
    
    func getListMovie(isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void) {
        isSearching = false
        if isResetLoadMore {
            isCanLoadMoreMovie = true
        }
        movieRepositoriy.getListMovie(isLoadMore && !isResetLoadMore ? (moviesCurrentPage + 1) : 1)
            .subscribe { [weak self] response in
                guard let self = self else { return }
                if isLoadMore {
                    self.movies.append(contentsOf: response.movies)
                    self.moviesCurrentPage = response.page
                } else {
                    self.movies = response.movies
                }
                completion()
            } onError: { [weak self] error in
                guard let self = self else { return }
                self.isCanLoadMoreMovie = false
                print(error)
                completion()
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func getCategories(completion: @escaping () -> Void) {
        genreRepositories.getCategories()
            .subscribe { [weak self] categoryResponse in
                self?.categories = categoryResponse.category
                self?.categories.removeAll(where: { $0.name.isEmpty })
                self?.categorySelected = self?.categories.first
            } onError: { error in
                print(error)
            } onCompleted: {
                completion()
            }.disposed(by: disposeBag)
    }
    
    func searchMovie(input: String, isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void) {
        isSearching = true
        if isResetLoadMore {
            isCanLoadMoreMovie = true
        }
        searchRepositories.searchMovies(input: input,
                                        page: isLoadMore && !isResetLoadMore ? (moviesCurrentPage + 1) : 1)
            .subscribe { [weak self] response in
                guard let self = self else { return }
                if isLoadMore {
                    self.movies.append(contentsOf: response.movies)
                    self.moviesCurrentPage = response.page
                } else {
                    self.movies = response.movies
                }
            } onError: { [weak self] error in
                guard let self = self else { return }
                self.isCanLoadMoreMovie = false
                print(error)
                completion()
            } onCompleted: {
                completion()
            }.disposed(by: disposeBag)
    }
    
    func didTapLike(index: Int, islike: Bool, voteCount: Int) {
        guard index < movies.count else { return }
        movies[index].isLike = islike
        movies[index].voteCount = voteCount
    }
    
    func diTapcategory(completion: @escaping () -> Void) {
        guard let inputSearch = categories.first(where: { $0.id == categorySelected?.id })?.name else { return }
        searchRepositories.searchMovies(input: inputSearch, page: 1)
            .subscribe { [weak self] movieRespon in
                self?.movies = movieRespon.movies
            } onError: { error in
                print(error)
            } onCompleted: {
                completion()
            }.disposed(by: disposeBag)
    }
}
