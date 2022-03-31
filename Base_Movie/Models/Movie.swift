//
//  Movie.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation

struct Movie: Codable {
    
    var isLike: Bool
    var backdropPath: String?
    var categoryIds: [Int]
    var id: Int
    var originalLanguage: String
    var originalTitle: String
    var overview: String
    var popularity: Double
    var posterPath: String?
    var releaseDate: String
    var title: String
    var video: Bool
    var voteAverage: Double
    var voteCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, overview, popularity, title, video
        case isLike = "adult"
        case backdropPath = "backdrop_path"
        case categoryIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    func getPosterURL() -> URL? {
        let URL = URL(string: AppConfig.imagePathString + (posterPath ?? ""))
        return URL
    }
    
    func getBackdropURL() -> URL? {
        let URL = URL(string: AppConfig.imagePathString + (backdropPath ?? ""))
        return URL
    }
}
