//
//  UserViewModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/22.
//

import UIKit

struct UserViewModel {
  var userObserver: DJObserverable<UserViewer> = DJObserverable()

  var userViewer: UserViewer? {
    return userObserver.value
  }

  func fetchUser(with name: String) async {
    if name.isEmpty || ConfigManager.checkOwner(by: name),
       let userViewer = ConfigManager.viewer {
      userObserver.value = userViewer
    }

    if let viewer = await UserManager.fetchUserInfo(by: name) {
      userObserver.value = viewer
      if ConfigManager.checkOwner(by: viewer.login) {
        LocalUserManager.saveUser(viewer)
      }
    }
  }

  mutating func update(_ userViewer: UserViewer?) {
    userObserver.value = userViewer
  }
}
