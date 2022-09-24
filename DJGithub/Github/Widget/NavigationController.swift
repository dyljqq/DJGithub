//
//  Navigation.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/24.
//

import UIKit

class NavigationController: UINavigationController {
  
  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let barApp = UINavigationBarAppearance()
    barApp.backgroundEffect = UIBlurEffect(style: .regular)
    navigationBar.scrollEdgeAppearance = barApp
  }
  
  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    if self.viewControllers.count > 1 {
      viewController.hidesBottomBarWhenPushed = true
    }
    super.pushViewController(viewController, animated: animated)
  }

}
