//
//  LocalDataManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/7.
//

import Foundation

enum LocalDataType {
  case repo
  case developer
}

struct LocalDataViewModel {
  
  let type: LocalDataType
  
  init(type: LocalDataType) {
    self.type = type
  }
  
  func loadData() async -> [DJCodable] {
    let task = Task { () -> [DJCodable] in
      switch type {
      case .developer:
        var rs: [DJCodable] = await DeveloperGroupManager.shared.loadFromDatabase()
        if rs.isEmpty {
          rs = await DeveloperGroupManager.shared.loadLocalDeveloperGroups()
        }
        return rs
      case .repo:
        return await LocalRepoManager.loadRepos()
      }
    }
    return await task.value
  }
  
}
