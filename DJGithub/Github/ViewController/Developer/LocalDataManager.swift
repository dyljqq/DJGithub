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

actor LocalDataHolder {
  var dataSource: [DJCodable] = []
  
  func setResults(_ results: [DJCodable]) {
    self.dataSource = results
  }
  
}

struct LocalDataViewModel {
  
  let type: LocalDataType
  var holder: LocalDataHolder = LocalDataHolder()
  
  init(type: LocalDataType) {
    self.type = type
  }
  
  func loadData() {
    Task {
      switch type {
      case .developer:
        var rs: [DJCodable] = await DeveloperGroupManager.shared.loadFromDatabase()
        if rs.isEmpty {
          rs = await DeveloperGroupManager.shared.loadLocalDeveloperGroups()
        }
        await holder.setResults(rs)
      case .repo:
        await holder.setResults(await LocalRepoManager.loadRepos())
      }
    }
  }
  
}
