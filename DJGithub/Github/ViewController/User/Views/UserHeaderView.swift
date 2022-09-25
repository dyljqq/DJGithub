//
//  UserHeaderView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit
import Kingfisher

class UserHeaderView: NormalHeaderView {
  func render(with model: User) {
    avatarImageView.kf.setImage(with: URL(string: model.avatarUrl))
    nameLabel.text = model.name ?? model.login
    loginLabel.text = "(\(model.login))"
    bioLabel.text = model.desc.trimmingCharacters(in: .whitespacesAndNewlines)
    if let joined = model.createdAt.split(separator: "T").first {
      joinedLabel.text = "Joined on \(String(describing: joined))"
    } else {
      joinedLabel.text = "Joined on \(model.createdAt)"
    }
    repoView.render(with: model.publicRepos, name: "Repos")
    followersView.render(with: model.followers, name: "Followers")
    followingView.render(with: model.following, name: "Following")
  }

}
