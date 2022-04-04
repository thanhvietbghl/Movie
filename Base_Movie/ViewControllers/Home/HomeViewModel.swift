//
//  HomeViewModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import Foundation
import RxSwift
import RxRelay

protocol HomeViewModelType {
    
    var movies: BehaviorRelay<[Movie]>{ get }
    var categories: BehaviorRelay<[Category]> { get }
    var categorySelected: BehaviorRelay<Category?> { get set }
    
    var didTapButtonSearch: PublishSubject<String?> { get set }
    var reloadMovieTableView: PublishSubject<Void> { get }
    var scrollToFistCell: PublishSubject<Void> { get }
    var reloadCategoryCollectionView: PublishSubject<Void> { get }
    var showError: PublishSubject<String> { get }
    var hideMoviesNoDataView: PublishSubject<Bool> { get }
    var didTapLike: PublishSubject<Movie> { get set }
    var didTapCategory: PublishSubject<Category> { get set }
    var showloadMoreMovieTableView: PublishSubject<Void> { get set }
    var didLoadMoreMovieTableView: PublishSubject<Void> { get set }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat
    func createMovieTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func createCategoryCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
}

final class HomeViewModel: HomeViewModelType {
    
    var movies = BehaviorRelay<[Movie]>(value: [])
    var categories = BehaviorRelay<[Category]>(value: [])
    
    var categorySelected = BehaviorRelay<Category?>(value: nil)
    var reloadMovieTableView = PublishSubject<Void>()
    var scrollToFistCell = PublishSubject<Void>()
    var reloadCategoryCollectionView = PublishSubject<Void>()
    var showError = PublishSubject<String>()
    var hideMoviesNoDataView = PublishSubject<Bool>()
    var didTapButtonSearch = PublishSubject<String?>()
    var didTapLike = PublishSubject<Movie>()
    var didTapCategory = PublishSubject<Category>()
    var showloadMoreMovieTableView = PublishSubject<Void>()
    var didLoadMoreMovieTableView = PublishSubject<Void>()
    
    let movieRepositoriy: MovieRepositories = MovieRepositoriesDefault()
    let categoryRepositories: CategoryRepositories = CategoryRepositoriesDefault()
    let searchRepositories: SearchRepositories = SearchRepositoriesDefault()
    
    private let disposeBag = DisposeBag()
    private var inputSearch = ""
    private var pageMovie: Int = 1
    private var categoryNameFont = AppFont.getFont(fontName: .regular, fontSize: 12)
    private var categoryNameHighlightFont = AppFont.getFont(fontName: .semiBold, fontSize: 12)
    
    init() {
        movies
            .subscribe(onNext: { [weak self] movies in
                guard let self = self else { return }
                self.hideMoviesNoDataView.onNext(!movies.isEmpty)
                self.reloadMovieTableView.onNext(())
                guard !movies.isEmpty else { return }
                self.scrollToFistCell.onNext(())
            }).disposed(by: disposeBag)
        
        categories
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                self.categorySelected.accept(categories.first)
                self.reloadCategoryCollectionView.onNext(())
            }).disposed(by: disposeBag)
        
        categorySelected
            .subscribe(onNext: { [weak self] category in
                guard let self = self, let input = category?.name else { return }
                self.inputSearch = input
                self.searchMovie(input: input)
            }).disposed(by: disposeBag)
        
        didTapButtonSearch
            .subscribe(onNext: { [weak self] input in
                guard let self = self, let input = input else { return }
                self.categorySelected.accept(input.isEmpty ? self.categories.value.first : nil)
                if !input.isEmpty {
                    self.inputSearch = input
                    self.searchMovie(input: input)
                }
            }).disposed(by: disposeBag)
        
        didTapLike
            .subscribe(onNext: { [weak self] movie in
                guard let self = self,
                let movieLikeIndex = self.movies.value.firstIndex(where: { $0.id == movie.id }) else { return }
                var movie = movie
                movie.isLike = !movie.isLike
                movie.voteCount = movie.isLike ? (movie.voteCount + 1) : (movie.voteCount - 1)
                var movies = self.movies.value
                movies.remove(at: movieLikeIndex)
                movies.insert(movie, at: movieLikeIndex)
                self.movies.accept(movies)
            }).disposed(by: disposeBag)
        
        didTapCategory
                .subscribe(onNext: { [weak self] category in
                guard let self = self else { return }
                self.categorySelected.accept(category)
            }).disposed(by: disposeBag)
        
        showloadMoreMovieTableView
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.loadMoreSearchMovie()
            }).disposed(by: disposeBag)
        
        getCategories()
    }
    
    func getWidthOfCategoryItem(indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < categories.value.count else { return 0 }
        let isCategorySelected = self.categorySelected.value?.id == categories.value[indexPath.row].id
        let fontAttributes = [NSAttributedString.Key.font: isCategorySelected ? categoryNameHighlightFont : categoryNameFont]
        let widthOfName: CGFloat = (categories.value[indexPath.row].name as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any]).width
        return widthOfName + AppConfig.widthBetweenLeftRightAndTitleButton
    }
    
    private func getCategories() {
        categoryRepositories.getCategories()
            .map({
                $0.categories.filter({ !$0.name.isEmpty })
            })
            .subscribe { [weak self] categories in
                guard let self = self else { return }
                self.categories.accept(categories)
            } onError: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
    
    private func searchMovie(input: String) {
        searchRepositories
            .searchMovies(input: input, page: 1)
            .map({ $0.movies })
            .subscribe(onNext: { [weak self] movies in
                guard let self = self else { return }
                self.movies.accept(movies)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.showError.onNext(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    private func loadMoreSearchMovie() {
        searchRepositories
            .searchMovies(input: self.inputSearch, page: pageMovie + 1)
            .map({ $0.movies })
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.pageMovie = self.pageMovie + 1
                var movies = self.movies.value
                movies.append(contentsOf: result)
                self.movies.accept(movies)
                self.didLoadMoreMovieTableView.onNext(())
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.showError.onNext(error.localizedDescription)
                self.didLoadMoreMovieTableView.onNext(())
            }).disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    
    func createMovieTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < movies.value.count else { return UITableViewCell() }
        let cellViewModel = MovieTableViewCellViewModel(movie: movies.value[indexPath.row],
                                                        didTapLike: didTapLike)
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier,
                                                 for: indexPath) as? MovieTableViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UITableViewCell()
    }
}

extension HomeViewModelType {
    
    func createCategoryCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < categories.value.count else { return UICollectionViewCell() }
        let cellViewModel = CategoryCollectionViewCellViewModel (
            categorySelected: categorySelected,
            category: categories.value[indexPath.row],
            didTapCategory: didTapCategory)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier,
                                                      for: indexPath) as? CategoryCollectionViewCell
        cell?.setup(viewModelType: cellViewModel)
        return cell ?? UICollectionViewCell()
    }
}
