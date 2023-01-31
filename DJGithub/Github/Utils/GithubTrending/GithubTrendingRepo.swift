//
//  GithubTrending.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import Foundation

struct GithubTrendingRepo: Codable {
    let id = UUID()

    let userName: String
    let repoName: String
    let languange: String
    let desc: String
    let star: String
    let fork: String
    let footerDesc: String
    let languageColor: String

    enum CodingKeys: String, CodingKey {
        case userName, repoName, languange, desc, star
        case fork, footerDesc, languageColor
    }
}

extension GithubTrendingRepo {
#if DEBUG
    static let sample: GithubTrendingRepo = GithubTrendingRepo(
        userName: "dyljqq",
        repoName: "DJGithub",
        languange: "Swift",
        desc: "DJGithub",
        star: "14",
        fork: "2",
        footerDesc: "2 stars today",
        languageColor: "0x000000"
    )
#endif
}
