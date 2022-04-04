//
//  BaseViewController.swift
//  Base_Movie
//
//  Created by Viet Phan on 04/04/2022.
//

import Foundation
import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    let disposeBag = DisposeBag()
    
    func showAlertWithMessage(message: String) {
        let alert = UIAlertController(title: "Movie App", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
