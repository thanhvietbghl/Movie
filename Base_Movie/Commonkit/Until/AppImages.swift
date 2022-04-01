//
//  AppImages.swift
//  Base_Movie
//
//  Created by Viet Phan on 01/04/2022.
//

import Foundation
import UIKit

struct AppImages {
        
    enum ImageName: String {
        case iconAvatar = "icon_avatar"
        case iconBack = "icon_back"
        case iconLikeDark = "icon_like_dark"
        case iconLikeSelected = "icon_like_selected"
        case iconLike = "icon_like"
        case iconLoadMore = "icon_load_more"
        case iconMovie = "icon_movie"
        case iconSearch = "icon_search"
        case iconStarSelected = "icon_star_selected"
        case iconStar = "icon_star"
        case iconWatchList = "icon_watch_list"
    }
    
    static func getImage(imageName: ImageName) -> UIImage? {
        return UIImage(named: imageName.rawValue)
    }
}
