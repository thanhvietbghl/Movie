//
//  CategoriesResponse.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation

struct CategoriesResponse: Codable {
    
    var category: [Category]
    
    enum CodingKeys: String, CodingKey {
        case category = "genres"
    }
}
