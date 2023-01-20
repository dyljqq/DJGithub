//
//  GithubTrendingView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import SwiftUI

struct GithubTrendingView: View {
    
    let types: [GithubTrendingType]
    let repoSelectedClosure: (GithubTrendingRepo) -> Void
    let developerSelectedClosure: (GithubTrendingDeveloper) -> Void
    
    @State var repos: [GithubTrendingRepo] = []
    @State var developers: [GithubTrendingDeveloper] = []
    @State var selectedIndex: Int = 0
    
    init(types: [GithubTrendingType],
         selectedIndex: Int,
         repoSelectedClosure: @escaping (GithubTrendingRepo) -> Void,
         developerSelectedClosure: @escaping (GithubTrendingDeveloper) -> Void
    ) {
        self.types = types
        self.selectedIndex = selectedIndex
        self.repoSelectedClosure = repoSelectedClosure
        self.developerSelectedClosure = developerSelectedClosure
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker("", selection: $selectedIndex) {
                ForEach(0..<types.count, id: \.self) { index in
                    let type = types[index]
                    switch type {
                    case .repo: Text("Repos")
                    case .developer: Text("Developers")
                    }
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 12, leading: 30, bottom: 12, trailing: 30))
            .onChange(of: selectedIndex) { index in
                loadData()
            }
            
            let type = types[selectedIndex]
            if case GithubTrendingType.repo = type, !repos.isEmpty {
                GithubTrendingReposView(with: repos) { index in
                    self.repoSelectedClosure(repos[index])
                }
            } else if case GithubTrendingType.developer = type, !developers.isEmpty {
                GithubTrendingDevelopersView(with: developers) { index in
                    self.developerSelectedClosure(developers[index])
                }
            } else {
                VStack {
                    LoaderView(tintColor: .gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        let type = types[selectedIndex]
        Task {
            switch type {
            case .repo:
                guard self.repos.isEmpty else { return }
                self.repos = await GithubTrendingParser(urlString: type.urlString).parse(with: .repo)
            case .developer:
                guard self.developers.isEmpty else { return }
                self.developers = await GithubTrendingParser(urlString: type.urlString).parse(with: .developer)
            }
        }
    }
}
