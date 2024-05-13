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
    
    func loadRepos() async {
        if let repos = GithubTrendingItemsManager.shared.load(with: .repo) as [GithubTrendingRepo]? {
            self.repos = repos
        }

        let type = GithubTrendingType.repo("/swift?since=daily")
        let repos: [GithubTrendingRepo] = await GithubTrendingParser(urlString: type.urlString).parse(with: .repo)
        self.repos = repos
    }

    func loadDevelopers() async {
        if let developers = GithubTrendingItemsManager.shared.load(with: .developer) as [GithubTrendingDeveloper]? {
            self.developers = developers
        }

        let type = GithubTrendingType.developer("/swift?since=daily")
        let developers: [GithubTrendingDeveloper] = await GithubTrendingParser(urlString: type.urlString).parse(with: .developer)
        self.developers = developers
    }

    func loadPamphletModels() async {
        pamphletModels = loadBundleJSONFile("PamphletData")
    }
    
}
