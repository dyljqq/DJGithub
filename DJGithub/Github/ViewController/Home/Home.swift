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
    var pamphletItemSelectedClosure: ((PamphletSectionModel.PamphletSimpleModel) -> Void)?
    
    @State var repos: [GithubTrendingRepo] = []
    @State var developers: [GithubTrendingDeveloper] = []
    @State var pamphletModels: [PamphletSectionModel] = []
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                
                if !pamphletModels.isEmpty {
                    ForEach(pamphletModels, id: \.sectionName) { section in
                        Section(header: Text("Important tasks")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                            .padding(.leading, 16)) {
                            ForEach(0..<section.displayItems.count, id: \.self) { index in
                                if let item = section.displayItems[index] as? PamphletSectionModel.PamphletSimpleModel {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            if let imageName = item.imageName {
                                                Image(uiImage: UIImage(named: imageName)!)
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                            }
                                            Text(item.title)
                                                .font(.system(size: 14))
                                                .foregroundColor(.textColor)
                                        }
                                        Divider()
                                    }
                                    .padding(.leading, 16)
                                    .padding(.top, 10)
                                    .onTapGesture {
                                        pamphletItemSelectedClosure?(item)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.backgroundColor)
        .onAppear {
            loadRepos()
            loadDevelopers()
            loadPamphletModels()
        }
    }
    
    private func loadRepos() {
        Task {
            let type = GithubTrendingType.repo("/swift?since=daily")
            let repos: [GithubTrendingRepo] = await GithubTrendingParser(urlString: type.urlString).parse(with: .repo)
            self.repos = repos.count > 5 ? Array(repos[0..<5]) : repos
        }
    }
    
    private func loadDevelopers() {
        Task {
            let type = GithubTrendingType.developer("/swift?since=daily")
            let developers: [GithubTrendingDeveloper] = await GithubTrendingParser(urlString: type.urlString).parse(with: .developer)
            self.developers = developers.count > 5 ? Array(developers[..<5]) : developers
        }
    }
    
    private func loadPamphletModels() {
        Task {
            pamphletModels = loadBundleJSONFile("PamphletData")
        }
    }
}
