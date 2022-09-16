//
//  UINavigation+Router.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import UIKit

extension UINavigationController {
  
  func pushToUser(with name: String) {
    let vc = UserViewController(name: name)
    self.pushViewController(vc, animated: true)
  }
  
}
