//
//  GithubTrendingItemsManager.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/30.
//

import Foundation

struct GithubTrendingItemsManager {
    static let shared = GithubTrendingItemsManager()
    
    func load<T: Codable>(with type: TrendingType) -> T? {
        do {
            return try JSONSerialization.loadJSON(withFilename: type.filename)
        } catch {
            print("Error to load data: \(error)")
        }
        return nil
    }
    
    func save<T: Codable>(with type: TrendingType, items: [T]) {
        guard let dict = DJEncoder(model: items).encode() else { return }
        do {
            try JSONSerialization.save(jsonObject: dict, toFilename: type.filename)
        } catch {
            print("Error to save file: \(error)")
        }
    }
    
}

extension GithubTrendingItemsManager {
    enum TrendingType {
        case repo
        case developer

        var dirName: String {
            return "GithubTrending"
        }
        
        var filename: String {
            switch self {
            case .repo: return "repo"
            case .developer: return "developer"
            }
        }
        
        var filePath: URL? {
            guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
            return documentURL.appendingPathComponent(filename, isDirectory: false)
        }
    }
}
