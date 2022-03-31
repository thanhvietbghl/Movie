//
//  UITableViewExtention.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import UIKit

extension UITableView {
    
    func registerCell<T: UITableViewCell>(ofType type: T.Type) {
        let nibName = String(describing: type)
        register(T.getNib(), forCellReuseIdentifier: nibName)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.identifier). Must register cell first.")
        }
        return cell
    }
}

extension UITableViewCell {
    
    static func getNib() -> UINib {
        let typeName = String(describing: self)
        let bundle = Bundle(for: self)
        return UINib(nibName: typeName, bundle: bundle)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
