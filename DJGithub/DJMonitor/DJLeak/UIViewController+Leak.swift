//
//  UIViewController+Leak.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/3.
//

import UIKit

extension UIViewController {
  @objc func swizzled_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    swizzled_present(viewControllerToPresent, animated: flag)

    _ = viewControllerToPresent.markAlive()
  }

  @objc func swizzled_viewDidAppear(_ animated: Bool) {
    swizzled_viewDidAppear(animated)

    watchAllProperties(with: 5)
  }
}

extension UINavigationController {
  @objc func swizzled_pushViewController(_ viewController: UIViewController, animated: Bool) {
    self.swizzled_pushViewController(viewController, animated: animated)
    _ = viewController.markAlive()
  }
}

extension UIView {
  @objc func swizzled_didMoveToSuperview() {
    self.swizzled_didMoveToSuperview()
    var hasAliveParent = false
    var r = self.next
    while r != nil {
      if r!.proxy != nil {
        hasAliveParent = true
        break
      }
      r = r!.next
    }
    if hasAliveParent {
      _ = self.markAlive()
    }
  }
}
