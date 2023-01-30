//
//  ReposTrendingView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/30.
//

import SwiftUI

struct ReposTrendingView: View {
    
    let items: [GithubTrendingRepo]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(0..<items.count, id: \.self) { index in
                    GithubTrendingRepoView(repo: items[index])
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.white)
                        }
                }
            }
        }
        .background(Color.backgroundColor)
    }
}

struct ReposTrendingView_Previews: PreviewProvider {
    static var previews: some View {
        ReposTrendingView(items: [
            GithubTrendingRepo.sample,
            GithubTrendingRepo.sample,
            GithubTrendingRepo.sample,
            GithubTrendingRepo.sample,
            GithubTrendingRepo.sample,
        ])
    }
}
