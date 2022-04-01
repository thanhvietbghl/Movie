//
//  HomeViewController.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

class HomeViewController: UIViewController, BindableType {
    
    @IBOutlet private weak var searhTextField: UITextField!
    @IBOutlet private weak var categoriesCollectionView: UICollectionView!
    @IBOutlet private weak var moviesTableView: BaseLoadMoreTableView!
    @IBOutlet private weak var moviesNoDataView: UIView!
    
    var viewModel: HomeViewModelType!
    var coodinator: HomeCoodinatorType!
    
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
        categoriesCollectionView.registerCell(ofType: CategoryCollectionViewCell.self)
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
    }
    
    private func setupTableView() {
        moviesTableView.registerCell(ofType: MovieTableViewCell.self)
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        moviesTableView.loadMoreDelegate = self
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        searhTextField.delegate = self
        searhTextField.attributedPlaceholder = NSAttributedString(
            string: "Search Here ...",
            attributes: [.foregroundColor: UIColor.white,
                         .font: AppFont.getFont(fontName: .regular, fontSize: 14)
            ]
        )
    }
    
    private func setupData() {
        viewModel.getCategories { [weak self] in
            guard let self = self else { return }
            self.categoriesCollectionView.reloadData()
            self.moviesTableView.reloadData()
            self.moviesNoDataView.isHidden = !self.viewModel.movies.isEmpty
        }
    }
    
    private func handleSearch() {
        guard let input = searhTextField.text else { return }
        if !input.isEmpty {
            viewModel.searchMovie(input: input,
                                  isSearchWithCategory: false,
                                  isLoadMore: false,
                                  isResetLoadMore: true) { [weak self] in
                guard let self = self else { return }
                self.moviesTableView.reloadData()
                if !self.viewModel.movies.isEmpty {
                    self.moviesTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                    at: .top,
                                                    animated: true)
                }
                self.moviesNoDataView.isHidden = !self.viewModel.movies.isEmpty
            }
        } else {
            guard let categoryName = viewModel.categorySelected?.name else { return }
            viewModel.searchMovie(input: categoryName,
                                  isSearchWithCategory: true,
                                  isLoadMore: false,
                                  isResetLoadMore: true) { [weak self] in
                guard let self = self else { return }
                self.moviesTableView.reloadData()
                self.moviesTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                at: .top,
                                                animated: true)
            }
        }
        if let index = viewModel.categories
            .firstIndex(where: { $0.id == viewModel.categorySelected?.id }) {
            categoriesCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("shaaa")
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       return createMovieTableViewCell(tableView: tableView,
                                       indexPath: indexPath)
    }
    
    private func createMovieTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.movies.count else { return UITableViewCell() }
        let cellViewModel = MovieTableViewCellViewModel(movie: viewModel.movies[indexPath.row],
                                                        didTapLike: { [weak self] (isLike, voteCount) in
            guard let self = self else { return }
            self.viewModel.didTapLike(index: indexPath.row,
                                      islike: isLike,
                                      voteCount: voteCount)
        })
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier,
                                                 for: indexPath) as? MovieTableViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UITableViewCell()
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.movies.count else { return }
        coodinator.showMovieDetail(movie: viewModel.movies[indexPath.row],
                                   categorys: viewModel.categories,
                                   delegate: self)
    }
}

extension HomeViewController: UIScrollViewDelegate, LoadMoreDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == moviesTableView else { return }
        self.moviesTableView.scrollViewDidScroll(scrollView)
    }
    
    func isShowLoadMore() -> Bool {
        return viewModel.isCanLoadMoreMovie
    }
    
    func showingLoadMore(handleDidLoadMoreSuccess: @escaping () -> Void) {
        if viewModel.isSearching {
            guard let input = searhTextField.text else { return }
            viewModel.searchMovie(input: input,
                                  isSearchWithCategory: false,
                                  isLoadMore: true,
                                  isResetLoadMore: false,
                                  completion: { [weak self] in
                guard let self = self else { return }
                self.moviesTableView.reloadData()
                handleDidLoadMoreSuccess()
            })
        } else {
            viewModel.getMovies(isLoadMore: true,
                                isResetLoadMore: false,
                                completion: { [weak self] in
                guard let self = self else { return }
                self.moviesTableView.reloadData()
                handleDidLoadMoreSuccess()
            })
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return createCategoryCollectionViewCell(collectionView: collectionView,
                                                indexPath: indexPath)
    }
    
    private func createCategoryCollectionViewCell(collectionView: UICollectionView,
                                                  indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < viewModel.categories.count else { return UICollectionViewCell() }
        let isSelectedCategory = viewModel.categories[indexPath.row].id == viewModel.categorySelected?.id && !viewModel.isSearching
        let cellViewModel = CategoryCollectionViewCellViewModel(
            isSelectedCategory: isSelectedCategory,
            category: viewModel.categories[indexPath.row],
            diTapcategory: { [weak self] in
                guard let self = self else { return }
                self.hanldeDidTapcategory(index: indexPath.row)
            })
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier,
                                                      for: indexPath) as? CategoryCollectionViewCell
        cell?.setup(viewModelType: cellViewModel,
                    categoryButtonFont: viewModel.categoryNameFont,
                    categoryButtonHighlightFont: viewModel.categoryNameHighlightFont)
        return cell ?? UICollectionViewCell()
    }
                                                        
    private func hanldeDidTapcategory(index: Int) {
        guard index < viewModel.categories.count else { return }
        self.searhTextField.text = nil
        let oldCatelorySelectedID = viewModel.categorySelected?.id
        let newCatelorySelected = viewModel.categories[index]
        viewModel.didTapcategory(categorySelected: newCatelorySelected) { [weak self] in
            guard let self = self else { return }
            if let indexOldCatelorySelectedID = self.viewModel.categories
                .firstIndex(where: { $0.id == oldCatelorySelectedID }) {
                self.categoriesCollectionView.reloadItems(at: [IndexPath(row: indexOldCatelorySelectedID, section: 0)])
            }
            guard let indexNewCatelorySelected = self.viewModel.categories
                .firstIndex(where: { $0.id == newCatelorySelected.id }) else { return }
            self.categoriesCollectionView.reloadItems(at: [IndexPath(row: indexNewCatelorySelected,
                                                                    section: 0)]
            )
            self.moviesTableView.reloadData()
            self.moviesTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                            at: .top,
                                            animated: true)
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = viewModel.getWidthOfCategoryItem(indexPath: indexPath)
        return CGSize(width: width,
                      height: collectionView.frame.height)
    }
}

extension HomeViewController: MovieDetailViewModelDelegate {
    
    func didTapLike(_ viewController: MovieDetailViewController,
                    movieID: Int,
                    islike: Bool,
                    voteCount: Int) {
        guard let index = viewModel.movies.firstIndex(where: { $0.id == movieID }) else { return }
        viewModel.didTapLike(index: index,
                             islike: islike,
                             voteCount: voteCount)
        moviesTableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                  with: .fade)
    }
}
