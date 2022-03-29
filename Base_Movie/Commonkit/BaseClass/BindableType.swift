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
    
    var viewModelType: ViewModelType! { get set }
    var coodinatorType: CoodinatorType! { get set }
}

extension BindableType where Self: UIViewController {
    
    func bind(to viewModelType: Self.ViewModelType, to coodinatorType: Self.CoodinatorType) {
        self.viewModelType = viewModelType
        self.coodinatorType = coodinatorType
        loadViewIfNeeded()
    }
}
