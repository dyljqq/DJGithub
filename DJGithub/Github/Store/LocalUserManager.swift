//
//  LocalUserManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/25.
//

import Foundation

struct LocalUserManager {
  
  static func getUser() -> UserViewer? {
    return DJUserDefaults.userInfo()
  }
  
  static func saveUser(_ user: UserViewer?) {
    DJUserDefaults.save(with: user)
  }
  
  static func loadViewer() {
    if getUser() == nil {
      Task {
        let viewer = await UserManager.fetchUserInfo()
        saveUser(viewer)
      }
    }
  }
  
}
