//
//  CategoryResponse.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation

struct CategoryResponse: Codable {
    
    var categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case categories = "genres"
    }
}
