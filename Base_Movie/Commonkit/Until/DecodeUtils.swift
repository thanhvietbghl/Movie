//
//  DecodeUtils.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation

struct DecodeUtils {
    
    static func decode<T: Decodable>(json: Any) -> T? {
        guard let json = json as? [String: Any] else { return nil }
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .withoutEscapingSlashes)
            let model = try jsonDecoder.decode(T.self, from: jsonData)
            return model
        } catch let error {
            print("Decode Failed: ", String(describing: T.self))
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func decodeArray<T: Decodable>(json: Any) -> [T]? {
        guard let json = json as? [Any] else { return nil }
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .withoutEscapingSlashes)
            let models = try jsonDecoder.decode([T].self, from: jsonData)
            return models
        } catch let error {
            print("Decode Array Failed: ", String(describing: T.self))
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func decode<T: Decodable>(data: Data?) -> T? {
        guard let data = data else { return nil }
        do {
            let jsonDecoder = JSONDecoder()
            let model = try jsonDecoder.decode(T.self, from: data)
            return model
        } catch let error {
            print("Decode Failed: ", String(describing: T.self))
            print(error.localizedDescription)
            return nil
        }
    }
}

