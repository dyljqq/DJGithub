//
//  RepoHeaderView.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/25.
//

import UIKit

class RepoHeaderView: NormalHeaderView {
  
  func render(with repo: Repository) {
    avatarImageView.setImage(with: URL(string: repo.owner?.avatarUrl ?? ""))
    nameLabel.text = repo.nameWithOwner
    bioLabel.text = repo.desc
    if let joined = repo.updatedAt.split(separator: "T").first {
      joinedLabel.text = "Updated on \(String(describing: joined))"
    } else {
      joinedLabel.text = "Updated on \(repo.updatedAt)"
    }
    repoView.render(with: repo.watchers.totalCount, name: "Watchs")
    followersView.render(with: repo.stargazers.totalCount, name: "Stars")
    followingView.render(with: repo.forkCount, name: "forks")
  }
  
}
