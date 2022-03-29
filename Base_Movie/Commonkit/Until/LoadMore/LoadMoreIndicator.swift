//
//  LoadMoreIndicator.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import UIKit

class LoadMoreIndicator: BaseNibView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var animationImage: UIImageView!
    
    func beginRotation() {
        animationImage.rotate()
    }
    
    func stopRotation() {
        animationImage.stopRotating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
}
