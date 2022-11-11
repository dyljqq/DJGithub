//
//  UIViewController+Share.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/8.
//

import UIKit

extension UIViewController {
  func share(with urlString: String) {
    guard let shareURL = URL(string: urlString) else { return }
    let sharedItems: [Any] = [shareURL]
    let activityVC = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
    self.present(activityVC, animated: true)
  }
  
  var naviVc: UIViewController? {
    var vc: UIViewController? = self
    while vc?.parent != nil && !(vc?.parent is UINavigationController) {
      vc = vc?.parent
    }
    return vc
  }
}
