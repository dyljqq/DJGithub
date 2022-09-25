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
    let vc = UserStaredReposViewController(userName: userName)
    self.pushViewController(vc, animated: true)
  }
  
  func pushToRepo(with repoName: String) {
    let vc = RepoViewController(repoName: repoName)
    self.pushViewController(vc, animated: true)
  }
}
