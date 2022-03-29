//
//  HomeViewController.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

class HomeViewController: UIViewController, BindableType {
    
    @IBOutlet private weak var searhTextField: UITextField!
    @IBOutlet private weak var moveTypeCollectionView: UICollectionView!
    @IBOutlet private weak var movieTableView: BaseLoadMoreTableView!
    @IBOutlet private weak var moviesEmptyView: UIView!
    
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
        moveTypeCollectionView.registerCell(ofType: CategoryCollectionViewCell.self)
        moveTypeCollectionView.dataSource = self
        moveTypeCollectionView.delegate = self
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
        viewModelType.getListMovie(isLoadMore: false,
                               isResetLoadMore: true) { [weak self] in
            self?.movieTableView.reloadData()
            self?.moviesEmptyView.isHidden = !(self?.viewModelType.movies.isEmpty ?? false)
        }
        viewModelType.getCategories { [weak self] in
            self?.moveTypeCollectionView.reloadData()
        }
    }
    
    private func handleSearch() {
        guard let input = searhTextField.text else { return }
        if !input.isEmpty {
            viewModelType.searchMovie(input: input,
                                  isLoadMore: false,
                                  isResetLoadMore: true) { [weak self] in
                self?.movieTableView.reloadData()
                self?.movieTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self?.moviesEmptyView.isHidden = !(self?.viewModelType.movies.isEmpty ?? false)
            }
        } else {
            if let index = viewModelType.categories
                .firstIndex(where: { $0.id == viewModelType.categorySelected?.id }) {
                viewModelType.categorySelected = nil
                moveTypeCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
            viewModelType.getListMovie(isLoadMore: false,
                                   isResetLoadMore: true) { [weak self] in
                self?.movieTableView.reloadData()
                self?.movieTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
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
        let cellViewModel = MovieTableViewCellViewModel(movie: viewModelType.movies[indexPath.row],
                                                        didTapLike: { [weak self] (isLike, voteCount) in
            self?.viewModelType.didTapLike(index: indexPath.row, islike: isLike, voteCount: voteCount)
        })
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell
        cell?.setUp(viewModel: cellViewModel)
        return cell!
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coodinatorType.showMovieDetail(movie: viewModelType.movies[indexPath.row],
                                   listGenres: viewModelType.categories,
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
                                  isLoadMore: true,
                                  isResetLoadMore: false,
                             completion: { [weak self] in
                self?.movieTableView.reloadData()
                handleDidLoadMoreSuccess()
            })
        } else {
            viewModelType.getListMovie(isLoadMore: true,
                                   isResetLoadMore: false,
                                   completion: { [weak self] in
                self?.movieTableView.reloadData()
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
        let cellViewModel = CategoryCollectionViewCellViewModel(
            isSelectedCategory: viewModelType.categories[indexPath.row].id == viewModelType.categorySelected?.id,
            genreModel: viewModelType.categories[indexPath.row],
            diTapcategory: { [weak self] in
                self?.hanldeDidTapcategory(index: indexPath.row)
            })
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell
        cell?.setup(viewModel: cellViewModel, categoryButtonFont: viewModelType.categoryNameFont, categoryButtonHighlightFont: viewModelType.categoryNameHighlightFont)
        return cell!
    }
                                                        
    private func hanldeDidTapcategory(index: Int) {
        let oldCatelorySelectedID = viewModelType.categorySelected?.id
        let newCatelorySelected = viewModelType.categories[index]
        viewModelType.categorySelected = newCatelorySelected
        if let indexOldCatelorySelectedID = viewModelType.categories
            .firstIndex(where: { $0.id == oldCatelorySelectedID }) {
            moveTypeCollectionView.reloadItems(at: [IndexPath(row: indexOldCatelorySelectedID, section: 0)])
        }
        guard let indexNewCatelorySelected = viewModelType.categories
            .firstIndex(where: { $0.id == newCatelorySelected.id }) else { return }
        moveTypeCollectionView.reloadItems(at: [IndexPath(row: indexNewCatelorySelected, section: 0)])
        viewModelType.diTapcategory() { [weak self] in
            self?.movieTableView.reloadData()
            self?.movieTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
    
    func didTapLike(movieID: Int, islike: Bool, voteCount: Int) {
        guard let index = viewModelType.movies.firstIndex(where: { $0.id == movieID }) else { return }
        viewModelType.didTapLike(index: index, islike: islike, voteCount: voteCount)
        movieTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
}
