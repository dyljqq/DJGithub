//
//  DeveloperGroupManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/3.
//

import Foundation

struct DeveloperGroupManager {
  static let NotificationUpdatedAllKey = "NotificationUpdatedAllKey"
  static let NotificationUpdatedAllName = NSNotification.Name(DeveloperGroupManager.NotificationUpdatedAllKey)
  
  static let shared = DeveloperGroupManager()
  
  func loadLocalDeveloperGroups() async -> [LocalDeveloperGroup] {
    let task = Task {
      let rs: [LocalDeveloperGroup] = loadBundleJSONFile("developerss.json")
      return rs
    }
    return await task.value
  }
  
  @discardableResult
  func update(with dev: LocalDeveloper) async -> LocalDeveloper? {
    guard let user = await UserManager.getUser(with: dev.name) else { return nil }
    
    if let developer = LocalDeveloper.get(by: user.login) {
      return LocalDeveloper.update(with: developer.name, des: developer.des ?? "", avatarUrl: user.avatarUrl)
    } else {
      var dev = dev
      dev.update(avatarUrl: user.avatarUrl)
      dev.insert()
    }
    return nil
  }
  
  func updateAll() async {
    let groups = await loadLocalDeveloperGroups()
    var developers: [LocalDeveloper] = []
    for group in groups {
      developers.append(contentsOf: group.users)
    }
    
    await withThrowingTaskGroup(of: Void.self) { group in
      for developer in developers {
        group.addTask {
          await update(with: developer)
        }
      }
    }
    
    NotificationCenter.default.post(
      name: DeveloperGroupManager.NotificationUpdatedAllName, object: nil)
  }
}
