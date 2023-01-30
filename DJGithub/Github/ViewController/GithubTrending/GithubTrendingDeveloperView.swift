//
//  GithubTrendingDeveloperView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/20.
//

import SwiftUI
import Kingfisher
import UIKit

struct GithubTrendingDeveloperView: View {

    let developer: GithubTrendingDeveloper

    let placeholderImage = UIImage(named: "person")!

    var body: some View {
        HStack(alignment: .top) {
            KFImage.url(URL(string: developer.avatarImageUrl))
                .placeholder {
                    Image(uiImage: placeholderImage)
                        .resizable()
                }
                .resizable()
                .frame(width: 44, height: 44)
                .cornerRadius(22)
            VStack(alignment: .leading) {
                HStack {
                    Text(developer.name)
                        .font(.system(size: 16))
                        .bold()
                        .foregroundColor(.blue)
                    Text("(\(developer.login))")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .textGrayColor))
                }
                HStack {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.red)
                        .frame(width: 16, height: 16)
                    Text("POPULAR REPO")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .textGrayColor))
                }
                HStack {
                    Image(systemName: "book.closed")
                        .resizable()
                        .frame(width: 13, height: 16)
                    Text(developer.repoName)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .bold()
                }
                Text(developer.repoDesc)
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .textGrayColor))
            }
            Spacer()
        }
        .padding()
    }
}

struct GithubTrendingDeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        GithubTrendingDeveloperView(
            developer: GithubTrendingDeveloper(
                avatarImageUrl: "https://avatars.githubusercontent.com/u/658?s=96&v=4",
                name: "Stephen Celis",
                login: "stephencelis",
                repoName: "SQLite.swift",
                repoDesc: "A type-safe, Swift-language"
            )
        )
    }
}
