//
//  GithubTrendingReposView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import SwiftUI

struct GithubTrendingReposView: View {
    
    let path: String
    
    private let baseUrlString = "https://github.com/trending"
    
    @State var repos: [GithubTrendingRepo] = []
    
    init(path: String = "", repos: [GithubTrendingRepo] = []) {
        self.path = path
        self.repos = repos
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(repos, id: \.id) { repo in
                    VStack {
                        GithubTrendingRepoView(repo: repo)
                        Rectangle()
                            .fill(Color(with: 244, green: 244, blue: 244))
                            .frame(height: 0.5)
                            .padding(.leading, 12)
                    }
                }
            }
        }
        .onAppear {
            Task {
                let urlString = baseUrlString + path
                self.repos = await GithubTrendingParser(urlString: urlString).parse()
            }
        }
    }
}

struct GithubTrendingRepos_Previews: PreviewProvider {
    
    static var previews: some View {
        GithubTrendingReposView(
            repos: [
                GithubTrendingRepo(userName: "dyljqq", repoName: "DJGithub", languange: "Swift", desc: "DJGithub", star: "14", fork: "2", footerDesc: "2 stars today"),
                GithubTrendingRepo(userName: "dyljqq", repoName: "DJGithub", languange: "Swift", desc: "DJGithub", star: "14", fork: "2", footerDesc: "2 stars today"),
                GithubTrendingRepo(userName: "dyljqq", repoName: "DJGithub", languange: "Swift", desc: "DJGithub", star: "14", fork: "2", footerDesc: "2 stars today"),
                GithubTrendingRepo(userName: "dyljqq", repoName: "DJGithub", languange: "Swift", desc: "DJGithub", star: "14", fork: "2", footerDesc: "2 stars today")
            ]
        )
    }
}
