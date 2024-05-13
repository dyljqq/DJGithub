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

    @State var viewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                Section {
                    LatestRssFeedItems(feedItemSelectedClosure: feedItemSelectedClosure)
                }

                if !viewModel.repos.isEmpty {
                    Section {
                        HomeHorizontalItemsView(
                            title: "Github Repo Trending:",
                            horizontalView: GithubTrendingItemView(
                                views: viewModel.repos.map { repo in
                                    GithubTrendingRepoView(repo: repo)
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                                        .onTapGesture {
                                            repoSelectedClosure?(repo)
                                        }
                                }
                            )
                        )
                    }
                }

                if !viewModel.developers.isEmpty {
                    Section {
                        HomeHorizontalItemsView(
                            title: "Github Developer Trending:",
                            horizontalView: GithubTrendingItemView(
                                views: viewModel.developers.map { developer in
                                    GithubTrendingDeveloperView(developer: developer)
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                                        .onTapGesture {
                                            developerSelectedClosure?(developer)
                                        }
                                }
                            )
                        )
                    }
                }

                if !viewModel.pamphletModels.isEmpty {
                    ForEach(viewModel.pamphletModels, id: \.sectionName) { section in
                        Section(header: Text(section.sectionName)
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
        .onViewDidLoad {
            reloadData()
        }
        .refreshable {
            reloadData()
        }
    }
    
    private func reloadData() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.viewModel.loadRepos()
                }
                group.addTask {
                    await self.viewModel.loadDevelopers()
                }
                group.addTask {
                    await self.viewModel.loadPamphletModels()
                }
                
            }
        }
    }
}
