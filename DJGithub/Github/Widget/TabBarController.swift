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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DJMonitor.shared.addFPSMonitor()
  }

  func setUp() {
    let userName = ConfigManager.shared.viewerName
    let staredVc = UserStaredReposViewController(userRepoState: .star(userName))
    staredVc.isViewer = true
    viewControllers = [
      setUp(for: PamphletViewController(type: .main), tabTitle: "Trending", image: UIImage(named: "group"), selectedImage: UIImage(named: "people")),
      setUp(for: FeedsViewController(), tabTitle: "Feeds", image: UIImage(named: "rss"), selectedImage: UIImage(named: "rss-feed")),
      setUp(for: staredVc, tabTitle: "Stars", image: UIImage(named: "star"), selectedImage: UIImage(named: "stared")),
      setUp(for: SearchViewController(with: [.users, .repos]), tabTitle: "Search", image: UIImage(named: "find"), selectedImage: UIImage(named: "search")),
      setUp(for: UserViewController(name: userName), tabTitle: "User", image: UIImage(named: "user"), selectedImage: UIImage(named: "person"))
    ]
  }

  private func setUp(for vc: UIViewController,
                     tabTitle title: String, image: UIImage?, selectedImage: UIImage?) -> UIViewController {
    let nav = NavigationController(rootViewController: vc)
    if let image = image, let data = image.pngData() {
      DispatchQueue.global().async {
        let img = ImageDecoder.downsampledImage(data: data, to: self.itemImageSize, scale: 1)?.withRenderingMode(.alwaysOriginal)
        DispatchQueue.main.async {
          nav.tabBarItem.image = img
        }
      }
    }
    if let selectedImage = selectedImage, let data = selectedImage.pngData() {
      DispatchQueue.global().async {
        let img = ImageDecoder.downsampledImage(data: data, to: self.itemImageSize, scale: 1)?.withRenderingMode(.alwaysOriginal)
        DispatchQueue.main.async {
          nav.tabBarItem.selectedImage = img
        }
      }
    }
    nav.tabBarItem.title = title
    return nav
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
