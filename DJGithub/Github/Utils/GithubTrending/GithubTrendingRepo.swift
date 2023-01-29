//
//  GithubTrending.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import Foundation

struct GithubTrendingRepo: Codable {
    var id = UUID()

    let userName: String
    let repoName: String
    let languange: String
    let desc: String
    let star: String
    let fork: String
    let footerDesc: String
    let languageColor: String
}
