//
//  GithubTrendingDeveloper.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/20.
//

import Foundation

struct GithubTrendingDeveloper: Codable {
    let avatarImageUrl: String
    let name: String
    let login: String
    let repoName: String
    let repoDesc: String

    var id = UUID()
}
