//
//  HomeViewController.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

class HomeViewController: UIViewController, BindableType {
    
    @IBOutlet private weak var searhTextField: UITextField!
    @IBOutlet private weak var movieTypeCollectionView: UICollectionView!
    @IBOutlet private weak var movieTableView: BaseLoadMoreTableView!
    @IBOutlet private weak var moviesNoDataView: UIView!
    
    var viewModelType: HomeViewModelType!
    var coodinatorType: HomeCoodinatorType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupUI()
        setupData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupCollectionView() {
        movieTypeCollectionView.registerCell(ofType: CategoryCollectionViewCell.self)
        movieTypeCollectionView.dataSource = self
        movieTypeCollectionView.delegate = self
    }
    
    private func setupTableView() {
        movieTableView.registerCell(ofType: MovieTableViewCell.self)
        movieTableView.dataSource = self
        movieTableView.delegate = self
        movieTableView.loadMoreDelegate = self
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        searhTextField.delegate = self
        searhTextField.attributedPlaceholder = NSAttributedString(
            string: "Search Here ...",
            attributes: [.foregroundColor: UIColor.white,
                         .font: UIFont.init(name: "Poppins", size: 15) ?? UIFont.systemFont(ofSize: 14)
            ]
        )
    }
    
    private func setupData() {
        viewModelType.getCategories { [weak self] in
            guard let self = self else { return }
            self.movieTypeCollectionView.reloadData()
            self.movieTableView.reloadData()
            self.moviesNoDataView.isHidden = !self.viewModelType.movies.isEmpty
        }
    }
    
    private func handleSearch() {
        guard let input = searhTextField.text else { return }
        if !input.isEmpty {
            viewModelType.searchMovie(input: input,
                                      isWithCategory: false,
                                      isLoadMore: false,
                                      isResetLoadMore: true) { [weak self] in
                guard let self = self else { return }
                self.movieTableView.reloadData()
                self.movieTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.moviesNoDataView.isHidden = !self.viewModelType.movies.isEmpty
            }
        } else {
            guard let categoryName = viewModelType.categorySelected?.name else { return }
            viewModelType.searchMovie(input: categoryName,
                                      isWithCategory: true,
                                      isLoadMore: false,
                                      isResetLoadMore: true) { [weak self] in
                guard let self = self else { return }
                self.movieTableView.reloadData()
                self.movieTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        if let index = viewModelType.categories
            .firstIndex(where: { $0.id == viewModelType.categorySelected?.id }) {
            movieTypeCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    @IBAction private func didTapSearch(_ sender: Any) {
        handleSearch()
    }
    
    @IBAction private func didTapWatchList(_ sender: Any) {
    }
}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        handleSearch()
        return true
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelType.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       return createMovieTableViewCell(tableView: tableView, indexPath: indexPath)
    }
    
    private func createMovieTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = MovieTableViewCellViewModel(movie: viewModelType.movies[indexPath.row],
                                                        didTapLike: { [weak self] (isLike, voteCount) in
            guard let self = self else { return }
            self.viewModelType.didTapLike(index: indexPath.row, islike: isLike, voteCount: voteCount)
        })
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell
        cell?.setUp(viewModel: cellViewModel)
        return cell ?? UITableViewCell()
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coodinatorType.showMovieDetail(movie: viewModelType.movies[indexPath.row],
                                       categorys: viewModelType.categories,
                                       delegate: self)
    }
}

extension HomeViewController: UIScrollViewDelegate, LoadMoreDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == movieTableView else { return }
        self.movieTableView.scrollViewDidScroll(scrollView)
    }
    
    func isShowLoadMore() -> Bool {
        return viewModelType.isCanLoadMoreMovie
    }
    
    func showingLoadMore(handleDidLoadMoreSuccess: @escaping () -> Void) {
        if viewModelType.isSearching {
            guard let input = searhTextField.text else { return }
            viewModelType.searchMovie(input: input,
                                      isWithCategory: false,
                                      isLoadMore: true,
                                      isResetLoadMore: false,
                                      completion: { [weak self] in
                guard let self = self else { return }
                self.movieTableView.reloadData()
                handleDidLoadMoreSuccess()
            })
        } else {
            viewModelType.getListMovie(isLoadMore: true,
                                   isResetLoadMore: false,
                                   completion: { [weak self] in
                guard let self = self else { return }
                self.movieTableView.reloadData()
                handleDidLoadMoreSuccess()
            })
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModelType.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return createCategoryCollectionViewCell(collectionView: collectionView, indexPath: indexPath)
    }
    
    private func createCategoryCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let isSelectedCategory = viewModelType.categories[indexPath.row].id == viewModelType.categorySelected?.id && !viewModelType.isSearching
        let cellViewModel = CategoryCollectionViewCellViewModel(
            isSelectedCategory: isSelectedCategory,
            category: viewModelType.categories[indexPath.row],
            diTapcategory: { [weak self] in
                guard let self = self else { return }
                self.hanldeDidTapcategory(index: indexPath.row)
            })
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell
        cell?.setup(viewModelType: cellViewModel, categoryButtonFont: viewModelType.categoryNameFont, categoryButtonHighlightFont: viewModelType.categoryNameHighlightFont)
        return cell ?? UICollectionViewCell()
    }
                                                        
    private func hanldeDidTapcategory(index: Int) {
        guard index < viewModelType.categories.count else { return }
        self.searhTextField.text = nil
        let oldCatelorySelectedID = viewModelType.categorySelected?.id
        let newCatelorySelected = viewModelType.categories[index]
        viewModelType.didTapcategory(categorySelected: newCatelorySelected) { [weak self] in
            guard let self = self else { return }
            if let indexOldCatelorySelectedID = self.viewModelType.categories
                .firstIndex(where: { $0.id == oldCatelorySelectedID }) {
                self.movieTypeCollectionView.reloadItems(at: [IndexPath(row: indexOldCatelorySelectedID, section: 0)])
            }
            guard let indexNewCatelorySelected = self.viewModelType.categories
                .firstIndex(where: { $0.id == newCatelorySelected.id }) else { return }
            self.movieTypeCollectionView.reloadItems(at: [IndexPath(row: indexNewCatelorySelected, section: 0)])
            self.movieTableView.reloadData()
            self.movieTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = viewModelType.getWidthOfCategoryItem(indexPath: indexPath)
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

extension HomeViewController: MovieDetailViewModelDelegate {
    
    func didTapLike(_ viewController: MovieDetailViewController, movieID: Int, islike: Bool, voteCount: Int) {
        guard let index = viewModelType.movies.firstIndex(where: { $0.id == movieID }) else { return }
        viewModelType.didTapLike(index: index, islike: islike, voteCount: voteCount)
        movieTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
}
