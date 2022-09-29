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
    
    let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    
    let barApp = UINavigationBarAppearance()
    barApp.backgroundEffect = UIBlurEffect(style: .regular)
    barApp.backButtonAppearance = backButtonAppearance
    navigationBar.scrollEdgeAppearance = barApp

    let barAppearace = UIBarButtonItem.appearance()
    barAppearace.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -60), for:UIBarMetrics.default)
    
  }
  
  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    if self.children.count == 1 {
      viewController.hidesBottomBarWhenPushed = true
    }
    super.pushViewController(viewController, animated: animated)
  }

}
