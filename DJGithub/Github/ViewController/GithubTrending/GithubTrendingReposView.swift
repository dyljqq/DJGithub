//
//  GithubTrendingReposView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import SwiftUI

struct GithubTrendingReposView: View {
    
    let urlString: String
    let itemDidSelectedClosure:((Int) -> Void)?
    
    @State var repos: [GithubTrendingRepo] = []
    
    init(with urlString: String, itemDidSelectedClosure: ((Int) -> Void)? = nil) {
        self.urlString = urlString
        self.itemDidSelectedClosure = itemDidSelectedClosure
    }
    
    init(with repos: [GithubTrendingRepo], itemDidSelectedClosure: ((Int) -> Void)? = nil) {
        self.urlString = ""
        self.repos = repos
        self.itemDidSelectedClosure = itemDidSelectedClosure
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(0..<repos.count, id: \.self) { index in
                    VStack {
                        GithubTrendingRepoView(repo: repos[index])
                        Divider()
                            .padding(.leading, 12)
                    }
                    .onTapGesture {
                        self.itemDidSelectedClosure?(index)
                    }
                }
            }
        }
    }
}

struct GithubTrendingRepos_Previews: PreviewProvider {
    
    static var previews: some View {
        GithubTrendingReposView(
            with: [
                GithubTrendingRepo(
                    userName: "dyljqq",
                    repoName: "DJGithub",
                    languange: "Swift",
                    desc: "DJGithub",
                    star: "14",
                    fork: "2",
                    footerDesc: "2 stars today",
                    languageColor: "0x000000"
                ),
                GithubTrendingRepo(
                    userName: "dyljqq",
                    repoName: "DJGithub",
                    languange: "Swift",
                    desc: "DJGithub",
                    star: "14",
                    fork: "2",
                    footerDesc: "2 stars today",
                    languageColor: "0x000000"
                ),
                GithubTrendingRepo(
                    userName: "dyljqq",
                    repoName: "DJGithub",
                    languange: "Swift",
                    desc: "DJGithub",
                    star: "14",
                    fork: "2",
                    footerDesc: "2 stars today",
                    languageColor: "0x000000"
                ),
                GithubTrendingRepo(
                    userName: "dyljqq",
                    repoName: "DJGithub",
                    languange: "Swift",
                    desc: "DJGithub",
                    star: "14",
                    fork: "2",
                    footerDesc: "2 stars today",
                    languageColor: "0x000000"
                )
            ]
        )
    }
}
