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

  init() {
    try? LocalDeveloper.createTable()
    try? LocalDeveloperGroup.createTable()
  }

  func loadFromDatabase() async -> [LocalDeveloperGroup] {
    let task = Task { () -> [LocalDeveloperGroup] in
      guard let groups = LocalDeveloperGroup.selectAll() as [LocalDeveloperGroup]? else { return [] }
      var rs: [LocalDeveloperGroup] = []

      for group in groups {
        let users = LocalDeveloper.get(by: group.id).compactMap { $0 }
        rs.append(LocalDeveloperGroup(
          id: group.id, name: group.name, users: users.compactMap { $0 }
        ))
      }
      return rs
    }
    return await task.value
  }

  func loadLocalDeveloperGroups() async -> [LocalDeveloperGroup] {
    let task = Task {
      let groups: [LocalDeveloperGroup] = loadBundleJSONFile("developers")
      return groups
    }
    return await task.value
  }

  @discardableResult
  func update(with dev: LocalDeveloper, groupId: Int) async -> LocalDeveloper? {
    guard let user = await UserManager.getUser(with: dev.name) else { return nil }

    let des = dev.des ?? user.bio
    if let developer = LocalDeveloper.get(by: user.login) {
      return LocalDeveloper.update(
        with: developer.name, des: des, avatarUrl: user.avatarUrl, groupId: groupId)
    } else {
      var dev = dev
      dev.avatarUrl = user.avatarUrl
      dev.groupId = groupId
      dev.des = des
      try? dev.insert()
    }
    return nil
  }

  func updateAll() async {
    let groups = await loadLocalDeveloperGroups()
    for group in groups {
      if let localDeveloperGroup = LocalDeveloperGroup.get(by: group.id) {
        LocalDeveloperGroup.update(by: localDeveloperGroup.id, name: group.name)
      } else {
        try? group.insert()
      }
    }

    await withThrowingTaskGroup(of: Void.self) { taskGroup in
      for group in groups {
        for developer in group.developers {
          taskGroup.addTask {
            await update(with: developer, groupId: group.id)
          }
        }
      }
    }

    NotificationCenter.default.post(
      name: DeveloperGroupManager.NotificationUpdatedAllName, object: nil)
  }
}
