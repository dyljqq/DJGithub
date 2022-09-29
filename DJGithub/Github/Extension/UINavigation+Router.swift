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
  
  func pushToRepoInteract(type: RepoInteractViewController.RepoInteractType, repo: Repo? = nil) {
    let vc = RepoInteractViewController(with: type)
    vc.repo = repo
    self.pushViewController(vc, animated: true)
  }
}
