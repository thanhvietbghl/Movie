//
//  BaseLoadMoreTableView.swift
//  Base_Movie
//
//  Created by Viet Phan on 27/03/2022.
//

import Foundation
import UIKit

protocol LoadMoreDelegate: AnyObject {
    
    func isShowLoadMore() -> Bool
    func showingLoadMore(handleDidLoadMoreSuccess: @escaping () -> Void)
}

class BaseLoadMoreTableView: UITableView {
    
    weak var loadMoreDelegate: LoadMoreDelegate?
    
    private var oldReachedBottom: Bool = false

    private lazy var loadingMoreView = {
        return LoadMoreIndicator(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    }()
    
    private var reachedBottom: Bool {
        set {
            let oldValue = oldReachedBottom
            oldReachedBottom = newValue
            guard newValue && newValue != oldValue,
                  let delegate = self.loadMoreDelegate else { return }
            delegate.isShowLoadMore() ? self.showLoadMore() : self.hideLoadMore()
        }
        get {
            return oldReachedBottom
        }
    }
}

extension BaseLoadMoreTableView {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let hasContent = scrollView.contentSize.height > 0
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        reachedBottom = scrollView.contentOffset.y >= maxScrollDistance && hasContent
    }
}

extension BaseLoadMoreTableView {
    
    func showLoadMore() {
        let isShowingLoadMore: Bool = self.tableFooterView?.isHidden == false
        if self.tableFooterView == nil {
            self.tableFooterView = self.loadingMoreView
        }
        if let frameWillScroll = self.tableFooterView?.frame {
            self.scrollRectToVisible(frameWillScroll, animated: true)
        }
        UIView.transition(with: self, duration: 0.3, options: .curveEaseIn, animations: {
            self.tableFooterView?.isHidden = false
            self.loadingMoreView.beginRotation()
        }, completion: { _ in
            if !isShowingLoadMore {
                self.loadMoreDelegate?.showingLoadMore(handleDidLoadMoreSuccess: { [weak self] in
                    guard let self = self else { return }
                    self.hideLoadMore()
                })
            }
        })
    }
    
    func hideLoadMore() {
        UIView.transition(with: self, duration: 0.3, options: .curveEaseOut, animations: {
            self.tableFooterView?.isHidden = true
            self.tableFooterView = nil
            self.loadingMoreView.stopRotation()
        }, completion: nil)
    }
}
