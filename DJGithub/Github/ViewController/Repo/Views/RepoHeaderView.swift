//
//  RepoHeaderView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit

class RepoHeaderView: NormalHeaderView {

  func render(with model: Repo) {
    avatarImageView.kf.setImage(with: URL(string: model.owner?.avatarUrl ?? ""))
    nameLabel.text = model.fullName
    bioLabel.text = model.desc
    if let joined = model.updatedAt.split(separator: "T").first {
      joinedLabel.text = "Updated on \(String(describing: joined))"
    } else {
      joinedLabel.text = "Updated on \(model.updatedAt)"
    }
    repoView.render(with: model.watchersCount, name: "Watchs")
    followersView.render(with: model.stargazersCount, name: "Stars")
    followingView.render(with: model.forksCount, name: "forks")
  }
  
}
