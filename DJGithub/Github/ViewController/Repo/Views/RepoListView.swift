//
//  RepoListView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/2/17.
//

import SwiftUI

struct RepoListView: View {
    
    @State var repos: [Repo] = []
    
    var body: some View {
        ScrollView {
            LazyVStack() {
                ForEach(repos, id: \.id) { repo in
                    SimpleRepoView(repo: repo)
                }
            }
        }
    }
    
    func loadData(from remote: Bool) {
        if let repos = DJUserDefaults.getStaredRepos() {
            self.repos = repos
        }
        
        Task {
            self.repos = await RepoManager.fetchStaredRepos(with: "dyljqq", page: 1)
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView(
            repos: [
                .sample, .sample, .sample,
                .sample, .sample, .sample,
                .sample, .sample, .sample,
            ]
        )
    }
}
