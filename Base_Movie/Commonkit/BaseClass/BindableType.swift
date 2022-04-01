//
//  BindableType.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import UIKit

protocol BindableType: AnyObject {
    
    associatedtype ViewModelType
    associatedtype CoodinatorType
    
    var viewModel: ViewModelType! { get set }
    var coodinator: CoodinatorType! { get set }
}

extension BindableType where Self: UIViewController {
    
    func bind(to viewModel: Self.ViewModelType, to coodinator: Self.CoodinatorType) {
        self.viewModel = viewModel
        self.coodinator = coodinator
        loadViewIfNeeded()
    }
}
