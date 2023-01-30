//
//  Home.swift
//  DJGithub
//
//  Created by jiqinqiang on 2023/1/29.
//

import SwiftUI

struct Home: View {
    
    var feedItemSelectedClosure: ((RssFeedLatestCellModel) -> Void)?
    var repoSelectedClosure: ((GithubTrendingRepo) -> Void)?
    var developerSelectedClosure: ((GithubTrendingDeveloper) -> Void)?
    
    @State var repos: [GithubTrendingRepo] = []
    @State var developers: [GithubTrendingDeveloper] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Section {
                    LatestRssFeedItems(feedItemSelectedClosure: feedItemSelectedClosure)
                }
                
                if !repos.isEmpty {
                    Section {
                        HomeHorizontalItemsView(
                            title: "Github Repo Trending:",
                            horizontalView: GithubTrendingItemView(
                                views: repos.map { repo in
                                    GithubTrendingRepoView(repo: repo)
                                        .onTapGesture {
                                            repoSelectedClosure?(repo)
                                        }
                                }
                            )
                        )
                    }
                }
                
                if !developers.isEmpty {
                    Section {
                        HomeHorizontalItemsView(
                            title: "Github Developer Trending:",
                            horizontalView: GithubTrendingItemView(
                                views: developers.map { developer in
                                    GithubTrendingDeveloperView(developer: developer)
                                        .onTapGesture {
                                            developerSelectedClosure?(developer)
                                        }
                                }
                            )
                        )
                    }
                }
            }
        }
        .background(Color.backgroundColor)
        .onAppear {
            loadRepos()
            loadDevelopers()
        }
    }
    
    private func loadRepos() {
        Task {
            let type = GithubTrendingType.repo("/swift?since=daily")
            let repos: [GithubTrendingRepo] = await GithubTrendingParser(urlString: type.urlString).parse(with: .repo)
            self.repos = repos.count > 5 ? Array(repos[0..<5]) : repos
            print("repos: \(repos.count)")
        }
    }
    
    private func loadDevelopers() {
        Task {
            let type = GithubTrendingType.developer("/swift?since=daily")
            let developers: [GithubTrendingDeveloper] = await GithubTrendingParser(urlString: type.urlString).parse(with: .developer)
            self.developers = developers.count > 5 ? Array(developers[..<5]) : developers
            print("developers: \(developers.count)")
        }
    }
}
