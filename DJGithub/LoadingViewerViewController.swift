//
//  ViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import UIKit

class LoadingViewerViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .backgroundColor
    
    view.startLoading()
    Task {
      ConfigManager.shared.load()
      let viewer = await LocalUserManager.loadViewer()
      view.stopLoading()
          
      if viewer == nil {
        HUD.show(with: "Error to load viewer info.")
      } else {
        UIApplication.shared.keyWindow?.rootViewController = TabBarController()
        
        await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            await DeveloperGroupManager.shared.updateAll()
          }
          group.addTask {
            await UserFollowingManager.shared.fetchUserFollowingStatus()
          }
        }
      }
    }
  }
}

