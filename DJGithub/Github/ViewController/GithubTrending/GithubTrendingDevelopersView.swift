//
//  GithubTrendingDevelopersView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/20.
//

import SwiftUI

struct GithubTrendingDevelopersView: View {
    
    @State var developers: [GithubTrendingDeveloper] = []
    
    let urlString: String
    let itemDidSelectedClosure: (Int) -> (Void)
    
    init(with urlString: String, itemDidSelectedClosure: @escaping (Int) -> (Void)) {
        self.urlString = urlString
        self.itemDidSelectedClosure = itemDidSelectedClosure
    }
    
    init(with developers: [GithubTrendingDeveloper], itemDidSelectedClosure: @escaping (Int) -> Void) {
        self.urlString = ""
        self.developers = developers
        self.itemDidSelectedClosure = itemDidSelectedClosure
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<developers.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        GithubTrendingDeveloperView(developer: developers[index])
                        Divider()
                            .padding(.leading, 12)
                    }
                    .onTapGesture {
                        itemDidSelectedClosure(index)
                    }
                }
            }
        }
    }
}

struct GithubTrendingDevelopersView_Previews: PreviewProvider {
    static var previews: some View {
        GithubTrendingDevelopersView(
            with: [
                GithubTrendingDeveloper(
                    avatarImageUrl: "https://avatars.githubusercontent.com/u/658?s=96&v=4",
                    name: "Stephen Celis",
                    login: "stephencelis",
                    repoName: "SQLite.swift",
                    repoDesc: "A type-safe, Swift-language layer over SQLite3."
                ),
                GithubTrendingDeveloper(
                    avatarImageUrl: "https://avatars.githubusercontent.com/u/658?s=96&v=4",
                    name: "Stephen Celis",
                    login: "stephencelis",
                    repoName: "SQLite.swift",
                    repoDesc: "A type-safe, Swift-language layer over SQLite3."
                ),
                GithubTrendingDeveloper(
                    avatarImageUrl: "https://avatars.githubusercontent.com/u/658?s=96&v=4",
                    name: "Stephen Celis",
                    login: "stephencelis",
                    repoName: "SQLite.swift",
                    repoDesc: "A type-safe, Swift-language layer over SQLite3."
                )
            ],
            itemDidSelectedClosure: { developer in
                
            }
        )
    }
}
