//
//  LocalUserManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/25.
//

import Foundation

struct LocalUserManager {
  
  static func getUser() -> User? {
    return DJUserDefaults.userInfo()
  }
  
  static func saveUser(_ user: User) {
    DJUserDefaults.save(with: user)
  }
  
  static func loadUserInfo(reloadClosure: ((User) -> ())? = nil) async {
    let userName = ConfigManager.config.userName
    if let user = await UserManager.getUser(with: userName) {
      guard let oldUser = getUser() else {
        DJUserDefaults.save(with: user)
        reloadClosure?(user)
        return
      }
      
      guard let dict = DJEncoder(model: user).encode(),
      let data = try? JSONSerialization.data(withJSONObject: dict),
      let userInfo = String(data: data, encoding: .utf8) else { return }
      
      let newMd5 = userInfo.md5
      if newMd5 != oldUser.md5 {
        DJUserDefaults.save(with: user)
        reloadClosure?(user)
      }
    }
  }
  
}
