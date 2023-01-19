//
//  GithubTrendingReposView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import SwiftUI

struct GithubTrendingReposView: View {
    
    let path: String
    let pushClosure:((String, String) -> Void)?
    
    private let baseUrlString = "https://github.com/trending"
    
    @State var repos: [GithubTrendingRepo] = []
    
    init(path: String = "", repos: [GithubTrendingRepo] = [], pushClosure: ((String, String) -> Void)? = nil) {
        self.path = path
        self.repos = repos
        self.pushClosure = pushClosure
    }
    
    var body: some View {
        VStack {
            if repos.isEmpty {
                LoaderView(tintColor: .gray)
            } else {
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
                            .onTapGesture {
                                self.pushClosure?(repo.userName, repo.repoName)
                            }
                        }
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
