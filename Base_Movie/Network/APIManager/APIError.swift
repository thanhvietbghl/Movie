//
//  APIError.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation

enum ResponseStatusCode: Int {
    
    case badGateway = 502
}

class APIError: NSObject, Codable, Error {
    
    var objectErrors: [String]
    var fieldErrors: [String: String]
    
    static let commonError = APIError(errorMessage: "error common")
    
    init(errorMessage: String) {
        self.objectErrors = [errorMessage]
        self.fieldErrors = [:]
    }
    
    init(error: Error) {
        if let apiError = error as? APIError {
            self.objectErrors = apiError.objectErrors
            self.fieldErrors = apiError.fieldErrors
        } else {
            self.objectErrors = [error.localizedDescription]
            self.fieldErrors = [:]
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let optionalContainer = try decoder.container(keyedBy: OptionalCodingKeys.self)
        
        self.objectErrors = (try? container.decodeIfPresent([String].self, forKey: CodingKeys.objectErrors)) ?? []
        self.fieldErrors = (try? container.decodeIfPresent([String: String].self, forKey: CodingKeys.fieldErrors)) ?? [:]
        
        let errorDetails = try? optionalContainer.decodeIfPresent(String.self, forKey: OptionalCodingKeys.errorDetails)
        if self.objectErrors.isEmpty && errorDetails != nil {
            self.objectErrors = [errorDetails ?? ""]
        }
    }
    
    override var description: String {
        get {
            return self.objectErrors.joined(separator: ", ")
        }
    }
    
    var errorDescription: String? {
        get {
            return self.description
        }
    }
    
    enum OptionalCodingKeys: String, CodingKey {
        case errorDetails
    }
    
    enum CodingKeys: String, CodingKey {
        case objectErrors
        case fieldErrors
    }
}
