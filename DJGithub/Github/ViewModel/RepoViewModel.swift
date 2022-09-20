//
//  RepoViewModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import Foundation

struct RepoViewModel {
  
  var page: Int = 1
  var isEnded: Bool = false
  var repos: [Repo] = []
  
  mutating func update(by page: Int, repos: [Repo], isEnded: Bool) {
    if page == 1 {
      self.repos = repos
    } else {
      self.repos.append(contentsOf: repos)
    }
    self.page = page
    self.isEnded = isEnded
  }
  
  static func fetchStaredRepos(with name: String, page: Int) async -> Repos? {
    let router = GithubRouter.userStartedRepos(path: name, queryItems: ["page": "\(page)"])
    let result = await APIClient.shared.get(by: router)
    switch result {
    case .success(let d):
      return DJDecoder<Repos>(dict:d).decode()
    case .failure(let error):
      print("fetchStaredRepos: \(error)")
    }
    return nil
  }
}
