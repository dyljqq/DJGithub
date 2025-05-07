//
//  HomeViewModel.swift
//  DJGithub
//
//  Created by polaris dev on 2024/5/13.
//

import Foundation

@Observable
class HomeViewModel {
    
    var repos: [GithubTrendingRepo] = []
    var developers: [GithubTrendingDeveloper] = []
    var pamphletModels: [PamphletSectionModel] = []
    
    static func loadRepos() async -> [GithubTrendingRepo] {
        if let repos = GithubTrendingItemsManager.shared.load(with: .repo) as [GithubTrendingRepo]? {
            return repos
        }

        let type = GithubTrendingType.repo("/swift?since=daily")
        let repos: [GithubTrendingRepo] = await GithubTrendingParser(urlString: type.urlString).parse(with: .repo)
        return repos
    }

    static func loadDevelopers() async -> [GithubTrendingDeveloper] {
        if let developers = GithubTrendingItemsManager.shared.load(with: .developer) as [GithubTrendingDeveloper]? {
            return developers
        }

        let type = GithubTrendingType.developer("/swift?since=daily")
        let developers: [GithubTrendingDeveloper] = await GithubTrendingParser(urlString: type.urlString).parse(with: .developer)
        return developers
    }

    static func loadPamphletModels() async -> [PamphletSectionModel] {
        return loadBundleJSONFile("PamphletData")
    }
    
}
