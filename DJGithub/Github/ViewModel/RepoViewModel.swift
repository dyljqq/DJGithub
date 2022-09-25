//
//  RepoViewModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import Foundation

struct RepoViewModel {
  
  static let pageStart = 1
  
  var page: Int = pageStart
  var isEnded: Bool = false
  var repos: [Repo] = []
  
  mutating func update(by page: Int, repos: [Repo], isEnded: Bool) {
    if page == RepoViewModel.pageStart {
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
  
  static func fetchRepo(with name: String) async -> Repo? {
    let router = GithubRouter.repo(name)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func userStaredRepo(with name: String) async -> Bool {
    let router = GithubRouter.userStaredRepo(name)
    let result = await APIClient.shared.get(by: router)
    switch result {
    case .success(let r):
      guard let statusCode = r["statusCode"] as? Int else {
        return false
      }
      return statusCode == 204
    case .failure:
      return false
    }
  }
  
  static func fetchREADME(with repoName: String) async -> Readme? {
    let router = GithubRouter.repoReadme(repoName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
}
