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
    var categorySelected: Category? { get }
    var isSearching: Bool { get }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat
    func getMovies(isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void)
    func getCategories(completion: @escaping () -> Void)
    func searchMovie(input: String, isSearchWithCategory: Bool, isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void)
    func didTapLike(index: Int, islike: Bool, voteCount: Int)
    func didTapcategory(categorySelected: Category, completion: @escaping () -> Void)
}

final class HomeViewModel: HomeViewModelType {
    
    var categoryNameFont = AppFont.getFont(fontName: .regular, fontSize: 12)
    var categoryNameHighlightFont = AppFont.getFont(fontName: .semiBold, fontSize: 12)
    var movies = [Movie]()
    var categories = [Category]()
    var categorySelected: Category?
    var isCanLoadMoreMovie: Bool = true
    var isSearching: Bool = false
    var moviesCurrentPage: Int = 1
    let movieRepositoriy: MovieRepositories = MovieRepositoriesDefault()
    let categoryRepositories: CategoryRepositories = CategoryRepositoriesDefault()
    let searchRepositories: SearchRepositories = SearchRepositoriesDefault()
    
    private let disposeBag = DisposeBag()
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < categories.count else { return 0 }
        let isCategorySelected = self.categorySelected?.id == categories[indexPath.row].id
        let fontAttributes = [NSAttributedString.Key.font: isCategorySelected ? categoryNameHighlightFont : categoryNameFont]
        let widthOfName: CGFloat = (categories[indexPath.row].name as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any]).width
        return widthOfName + AppConfig.widthBetweenLeftRightAndTitleButton
    }
    
    func getMovies(isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void) {
        isSearching = false
        if isResetLoadMore {
            isCanLoadMoreMovie = true
        }
        movieRepositoriy.getMovies(isLoadMore && !isResetLoadMore ? (moviesCurrentPage + 1) : 1)
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
        categoryRepositories.getCategories()
            .subscribe { [weak self] categoryResponse in
                guard let self = self else { return }
                self.categories = categoryResponse.categories
                self.categories.removeAll(where: { $0.name.isEmpty })
                self.categorySelected = self.categories.first
                guard let name = self.categorySelected?.name
                else {
                    completion()
                    return
                }
                self.searchMovie(input: name, isSearchWithCategory: true, isLoadMore: false, isResetLoadMore: true, completion: completion)
            } onError: { error in
                print(error)
            } onCompleted: {
                completion()
            }.disposed(by: disposeBag)
    }
    
    func searchMovie(input: String, isSearchWithCategory: Bool, isLoadMore: Bool, isResetLoadMore: Bool, completion: @escaping () -> Void) {
        isSearching = !isSearchWithCategory
        if isResetLoadMore {
            isCanLoadMoreMovie = true
        }
        searchRepositories.searchMovies(input: input, page: isLoadMore && !isResetLoadMore ? (moviesCurrentPage + 1) : 1)
            .subscribe { [weak self] response in
                guard let self = self else { return }
                if !isLoadMore {
                    self.movies = response.movies
                } else if !response.movies.isEmpty {
                    self.movies.append(contentsOf: response.movies)
                    self.moviesCurrentPage = self.moviesCurrentPage + 1
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
    
    func didTapLike(index: Int, islike: Bool, voteCount: Int) {
        guard index < movies.count else { return }
        movies[index].isLike = islike
        movies[index].voteCount = voteCount
    }
    
    func didTapcategory(categorySelected: Category, completion: @escaping () -> Void) {
        self.categorySelected = categorySelected
        guard let input = categories.first(where: { $0.id == categorySelected.id })?.name else { return }
        self.searchMovie(input: input, isSearchWithCategory: true, isLoadMore: false, isResetLoadMore: true, completion: completion)
    }
}
