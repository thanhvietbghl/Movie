//
//  UIImageViewExtention.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation
import Kingfisher
import Photos

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func setImage(url: URL?, placeHolder: UIImage?, resize: CGSize = .zero, isShowLoading: Bool = true, isForceReload: Bool = false, completion: (() -> Void)? = nil) {
        if isShowLoading {
            self.kf.indicatorType = .activity
        }
        if let url = url {
            var options: [KingfisherOptionsInfoItem] = [.transition(.fade(0.25))]
            if resize.width != 0 && resize.height != 0 {
                let processor = DownsamplingImageProcessor(size: resize)
                options = [
                    .processor(processor),
                    .cacheOriginalImage,
                    .scaleFactor(UIScreen.main.scale)
                ]
            }
            if isForceReload {
                options.append(.forceRefresh)
            }
            self.kf.setImage(with: url, placeholder: placeHolder, options: options) { _ in
                completion?()
            }
        } else {
            self.kf.setImage(with: url, placeholder: placeHolder) { _ in
                completion?()
            }
        }
    }
    
    func setImage(url: URL?, placeHolderImageName: String, completion: (() -> Void)? = nil) {
        self.setImage(url: url, placeHolder: UIImage(named: placeHolderImageName), completion: completion)
    }
}
