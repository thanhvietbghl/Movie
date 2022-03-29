//
//  MovieResponse.swift
//  Base_Movie
//
//  Created by Viet Phan on 25/03/2022.
//

import Foundation

struct MovieResponse: Codable {
    
    var page: Int
    var movies: [Movie]
    var totalPages: Int
    var totalResults: Int
    
    private enum CodingKeys: String, CodingKey {
        case page
        case movies = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
// name
struct ReviewsResponse: Codable {
    
    var id: Int
    var page: Int
    var reviews: [Review]
    var totalPages: Int
    var totalResults: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, page
        case reviews = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
