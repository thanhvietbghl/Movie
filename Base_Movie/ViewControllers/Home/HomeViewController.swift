//
//  HomeViewController.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class HomeViewController: BaseViewController, BindableType {
    
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
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        searhTextField.delegate = self
        searhTextField.attributedPlaceholder = NSAttributedString(
            string: "Search Here ...",
            attributes: [.foregroundColor: UIColor.white,
                         .font: AppFont.getFont(fontName: .regular, fontSize: 14)
            ]
        )
    }
        
    private func bind() {
        viewModel
            .reloadMovieTableView
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.moviesTableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel
            .scrollToFistCell
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.moviesTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel
            .showError
            .subscribe (onNext: { [weak self] error in
                guard let self = self else { return }
                self.showAlertWithMessage(message: error)
            }).disposed(by: disposeBag)
        
        viewModel
            .hideMoviesNoDataView
            .asDriver(onErrorJustReturn: true)
            .drive(moviesNoDataView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel
            .reloadCategoryCollectionView
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.categoriesCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    @IBAction private func didTapSearch(_ sender: Any) {
        viewModel.didTapButtonSearch.onNext(searhTextField.text)
    }
    
    @IBAction private func didTapWatchList(_ sender: Any) {
    }
}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        viewModel.didTapButtonSearch.onNext(textField.text)
        return true
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.createMovieTableViewCell(tableView: tableView, indexPath: indexPath)
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.movies.value.count else { return }
        coodinator.showMovieDetail(movie: viewModel.movies.value[indexPath.row],
                                   categorys: viewModel.categories.value,
                                   delegate: self)
    }
}

extension HomeViewController: UIScrollViewDelegate, LoadMoreDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == moviesTableView else { return }
        self.moviesTableView.scrollViewDidScroll(scrollView)
    }
    
    func isShowLoadMore() -> Bool {
        return true
    }
    
    func showingLoadMore(handleDidLoadMoreSuccess: @escaping () -> Void) {
        viewModel.showloadMoreMovieTableView.onNext(())
        viewModel.didLoadMoreMovieTableView
            .subscribe(onNext: { _ in
                handleDidLoadMoreSuccess()
            }).disposed(by: disposeBag)
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return createCategoryCollectionViewCell(collectionView: collectionView,
                                                indexPath: indexPath)
    }
    
    private func createCategoryCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return viewModel.createCategoryCollectionViewCell(collectionView: collectionView, indexPath: indexPath)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = viewModel.getWidthOfCategoryItem(indexPath: indexPath)
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

extension HomeViewController: MovieDetailViewModelDelegate {
    
    func didTapLike(_ viewController: MovieDetailViewController, movie: Movie) {
        viewModel.didTapLike.onNext(movie)
    }
}
