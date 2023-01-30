//
//  GithubTrendingType.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/20.
//

import Foundation

enum GithubTrendingType {
    case repo(String)
    case developer(String)
}

extension GithubTrendingType {

    var urlString: String {
        switch self {
        case .repo(let path): return "https://github.com/trending" + path
        case .developer(let path): return "https://github.com/trending/developers" + path
        }
    }
}
