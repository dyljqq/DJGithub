//
//  GithubTrendingRepoView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import SwiftUI

struct GithubTrendingRepoView: View {

    let repo: GithubTrendingRepo

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "book.closed")
                Text("\(repo.userName) /")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                Text(repo.repoName)
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .bold()
            }
            .padding(.bottom, 4)
            Text(repo.desc)
                .font(.system(size: 12))
                .foregroundColor(Color(uiColor: UIColor.textColor))
                .padding(.bottom, 8)
            HStack {
                HStack {
                    Circle()
                        .fill(Color(with: repo.languageColor))
                        .frame(width: 14, height: 14)
                    Text(repo.languange)
                        .font(.system(size: 12))
                        .foregroundColor(Color(uiColor: .textGrayColor))
                }
                Spacer()
                HStack {
                    Image(systemName: "star")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text(repo.star)
                        .font(.system(size: 12))
                        .foregroundColor(Color(uiColor: .textGrayColor))
                }
                Spacer()
                HStack {
                    Image("git-branch")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text(repo.fork)
                        .font(.system(size: 12))
                        .foregroundColor(Color(uiColor: .textGrayColor))
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
    }
}

struct GithubTrendingRepoView_Previews: PreviewProvider {
    static var previews: some View {
        GithubTrendingRepoView(
            repo: GithubTrendingRepo(
                userName: "dyljqq",
                repoName: "DJGithub",
                languange: "Swift",
                desc: "DJGithub",
                star: "14",
                fork: "2",
                footerDesc: "2 stars today",
                languageColor: "0x242424"
            )
        )
    }
}
