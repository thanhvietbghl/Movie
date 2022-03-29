//
//  ReviewsCollectionViewCell.swift
//  Base_Movie
//
//  Created by Viet Phan on 26/03/2022.
//

import UIKit

class ReviewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataView: UIView!
    
    private var viewModel: ReviewsCollectionViewCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }
    
    func setup(viewModel: ReviewsCollectionViewCellViewModel) {
        self.viewModel = viewModel
        tableView.isHidden = self.viewModel?.listReviews.isEmpty ?? true
        noDataView.isHidden = !(self.viewModel?.listReviews.isEmpty ?? true)
    }
    
    func setupTableView() {
        tableView.registerCell(ofType: ReviewsTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ReviewsCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.listReviews.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else { return UITableViewCell() }
        let cellViewModel = ReviewsTableViewCellViewModel(review: viewModel.listReviews[indexPath.row])
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewsTableViewCell.identifier, for: indexPath) as? ReviewsTableViewCell
        cell?.setup(viewModel: cellViewModel)
        return cell ?? UITableViewCell()
    }
}
