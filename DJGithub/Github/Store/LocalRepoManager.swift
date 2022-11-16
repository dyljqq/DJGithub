//
//  LocalRepoManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/7.
//

import Foundation

struct LocalRepoManager {

  static let fileName = "repos"

  static func loadRepos() async -> [LocalRepoGroup] {
    return await Task { () -> [LocalRepoGroup] in
      let rs: [LocalRepoGroup] = loadBundleJSONFile(fileName)
      return rs
    }.value
  }

}
