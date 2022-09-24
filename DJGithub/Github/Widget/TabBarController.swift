//
//  TabBar.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/24.
//

import UIKit

class TabBarController: UITabBarController {

  let itemImageSize = CGSize(width: 30, height: 30)
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    let barAppearance = UITabBarAppearance()
    barAppearance.configureWithOpaqueBackground()
    barAppearance.backgroundEffect = UIBlurEffect(style: .regular)
    
    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.normal.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
      NSAttributedString.Key.foregroundColor: UIColor.gray
    ]
    itemAppearance.selected.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
      NSAttributedString.Key.foregroundColor: UIColor.black
    ]
    
    barAppearance.stackedLayoutAppearance = itemAppearance
    tabBar.scrollEdgeAppearance = barAppearance
    tabBar.standardAppearance = barAppearance
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  func setUp() {
    viewControllers = [
      setUp(for: UserStaredReposViewController(userName: "dyljqq"), tabTitle: "星星", image: UIImage(named: "star"), selectedImage: UIImage(named: "stared")),
      setUp(for: UserViewController(name: "dyljqq"), tabTitle: "User", image: UIImage(named: "user"), selectedImage: UIImage(named: "person"))
    ]
  }
  
  private func setUp(for vc: UIViewController,
                     tabTitle title: String, image: UIImage?, selectedImage: UIImage?) -> UIViewController {
    let nav = NavigationController(rootViewController: vc)
    var image1: UIImage? = nil, selectedImage1: UIImage? = nil
    if let image = image, let data = image.pngData() {
      nav.tabBarItem.image = ImageDecoder.downsampledImage(data: data, to: itemImageSize, scale: 1)?.withRenderingMode(.alwaysOriginal)
    }
    if let selectedImage = selectedImage, let data = selectedImage.pngData() {
      nav.tabBarItem.selectedImage = ImageDecoder.downsampledImage(data: data, to: itemImageSize, scale: 1)?.withRenderingMode(.alwaysOriginal)
    }
    vc.tabBarItem.title = title
    return nav
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
