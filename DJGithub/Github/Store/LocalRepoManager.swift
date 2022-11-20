//
//  LocalRepoManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/7.
//

import Foundation

struct LocalRepoManager {

  static func loadRepos(with filename: String? = nil) async -> [LocalRepoGroup] {
    guard let filename else { return [] }
    return loadBundleJSONFile(filename)
  }

}
