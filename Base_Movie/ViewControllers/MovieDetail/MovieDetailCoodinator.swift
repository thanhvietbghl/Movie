//
//  MovieCoodinator.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import UIKit

protocol MovieDetailCoodinatorType {
    func finish()
}

final class MovieDetailCoodinator: MovieDetailCoodinatorType {
    
    private let navigation: UINavigationController
        
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func finish() {
        navigation.popViewController(animated: true)
    }
}
