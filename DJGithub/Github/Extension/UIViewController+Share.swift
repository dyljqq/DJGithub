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
}
