//
//  SimpleRepoView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/2/17.
//

import SwiftUI
import Kingfisher

struct SimpleRepoView: View {
    
    let repo: Repo
    
    var body: some View {
        HStack(alignment: .top) {
            KFImage.url(URL(string: repo.owner?.avatarUrl ?? ""))
                .placeholder {
                    Image.placeholderImage
                        .resizable()
                }
                .resizable()
                .frame(width: 44, height: 44)
                .cornerRadius(22)
            VStack(alignment: .leading, spacing: 5) {
                Text(repo.fullName)
                    .font(.system(size: 14))
                    .foregroundColor(.lightBlue)
                Text(repo.desc)
                    .font(.system(size: 12))
                    .foregroundColor(.textColor)
                Text("Updated on \(repo.updatedAt)")
                    .font(.system(size: 12))
                    .foregroundColor(.textGrayColor)
                footer
            }
        }
    }
    
    var footer: some View {
        HStack {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                Text(repo.language ?? "Unknown")
                    .font(.system(size: 12))
                    .foregroundColor(.textColor)
            }
            footerItem("star", text: "7.2k")
            footerItem("git-branch", text: "1.1k")
        }
    }
    
    func footerItem(_ imageName: String, text: String) -> some View {
        HStack {
            Image(uiImage: UIImage(named: imageName)!)
                .resizable()
                .frame(width: 12, height: 12)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.textColor)
        }
    }
}

struct SimpleRepoView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleRepoView(repo: .sample)
    }
}
