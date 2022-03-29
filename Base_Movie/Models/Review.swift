//
//  RevieModel.swift
//  Base_Movie
//
//  Created by Viet Phan on 27/03/2022.
//

import Foundation

struct Review: Codable {

    var authorName: String
    var authorDetails: Author
    var content: String
    var createdAt: String
    var id: String
    var updatedAt: String
    var url: String
    
    private enum CodingKeys: String, CodingKey {
        case authorName = "author"
        case content, id, url
        case authorDetails = "author_details"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Author: Codable {
    
    var name: String
    var username: String
    var avatarPath: String?
    var rating: Int?
    
    private enum CodingKeys: String, CodingKey {
        case name, username, rating
        case avatarPath = "avatar_path"
    }
    
    func getAvatarURL() -> URL? {
        let URL = URL(string: AppConfig.imagePathString + (avatarPath ?? ""))
        return URL
    }
}
