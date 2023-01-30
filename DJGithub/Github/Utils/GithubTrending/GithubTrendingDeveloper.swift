//
//  GithubTrendingDeveloper.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/20.
//

import Foundation

struct GithubTrendingDeveloper: Codable {
    
    let id = UUID()
    
    let avatarImageUrl: String
    let name: String
    let login: String
    let repoName: String
    let repoDesc: String
    
    enum CodingKeys: String, CodingKey {
        case avatarImageUrl, name, login, repoName, repoDesc
    }
}
