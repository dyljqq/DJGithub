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
    avatarImageView.setImage(with: model.avatarUrl)
    self.arrowImageView.isHidden = !ConfigManager.checkOwner(by: model.login)
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
  
  func render(with userViewer: UserViewer) {
    avatarImageView.setImage(with: userViewer.avatarUrl)
    self.arrowImageView.isHidden = userViewer.viewerCanFollow
    nameLabel.text = userViewer.name ?? userViewer.login
    loginLabel.text = "(\(userViewer.login))"
    bioLabel.text = userViewer.bio.trimmingCharacters(in: .whitespacesAndNewlines)
    if let joined = userViewer.createdAt.split(separator: "T").first {
      joinedLabel.text = "Joined on \(String(describing: joined))"
    } else {
      joinedLabel.text = "Joined on \(userViewer.createdAt)"
    }
    repoView.render(with: userViewer.repositories.totalCount, name: "Repos")
    followersView.render(with: userViewer.followers.totalCount, name: "Followers")
    followingView.render(with: userViewer.following.totalCount, name: "Following")
  }
  
  func render(with organization: Organization) {
    avatarImageView.setImage(with: organization.avatarUrl)
    self.arrowImageView.isHidden = true
    
    nameLabel.text = organization.name.isEmpty ? organization.login : organization.name
    loginLabel.text = organization.login
    bioLabel.text = organization.description.trimmingCharacters(in: .whitespacesAndNewlines)
    if let joined = organization.createdAt.split(separator: "T").first {
      joinedLabel.text = "Joined on \(String(describing: joined))"
    } else {
      joinedLabel.text = "Joined on \(organization.createdAt)"
    }
    repoView.render(with: organization.pinnableItems.totalCount, name: "Repos")
    followersView.render(with: 0, name: "Followers")
    followingView.render(with: 0, name: "Following")
  }
}
