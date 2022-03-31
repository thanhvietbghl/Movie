//
//  CollectionViewExtention.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

extension UICollectionView {
    
    func registerCell<T: UICollectionViewCell>(ofType type: T.Type) {
        let typeName = String(describing: type)
        self.register(T.getNib(), forCellWithReuseIdentifier: typeName)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.identifier). Must register cell first")
        }
        return cell
    }
}

extension UICollectionViewCell {
    
    static func getNib() -> UINib {
        let typeName = String(describing: self)
        let bundle = Bundle(for: self)
        return UINib(nibName: typeName, bundle: bundle)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
