//
//  UINavigation+Router.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

extension UINavigationController {
  
  func pushToUser(with userName: String) {
    let vc = UserViewController(name: userName)
    self.pushViewController(vc, animated: true)
  }
  
  func pushToUserStaredRepo(with userName: String) {
    let vc = UserStaredReposViewController(userRepoState: .star(userName))
    self.pushViewController(vc, animated: true)
  }
  
  func pushToRepo(with repoName: String) {
    let vc = RepoViewController(repoName: repoName)
    self.pushViewController(vc, animated: true)
  }
  
  func pushToWebView(with urlString: String? = nil, request: URLRequest? = nil) {
    let vc: WebViewController
    if let request = request {
      vc = WebViewController(with: request)
    } else {
      vc = WebViewController(with: urlString ?? "")
    }
    self.pushViewController(vc, animated: true)
  }
  
  func pushToRepoInteract(with repo: Repo, selectedIndex: Int = 0) {
    let repoName = repo.fullName
    let types: [RepoInteractViewController.RepoInteractType] = [
      .watches(repoName),
      .star(repoName),
      .forks(repoName),
      .contributor(repoName)
    ]
    let vc = RepoInteractViewController(with: types, selectedIndex: selectedIndex)
    vc.repo = repo
    self.pushViewController(vc, animated: true)
  }
  
  func pushToUserInteract(with user: User, selectedIndex: Int = 0) {
    let userName = user.login
    let types: [RepoInteractViewController.RepoInteractType] = [
      .repositories(userName),
      .followers(userName),
      .following(userName),
      .userStar(userName),
      .userWatches(userName)
    ]
    let vc = RepoInteractViewController(with: types, selectedIndex: selectedIndex)
    vc.user = user
    self.pushViewController(vc, animated: true)
  }
}
