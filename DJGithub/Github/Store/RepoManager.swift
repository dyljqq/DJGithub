//
//  RepoManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import Foundation

struct RepoManager {
  
  static let pageStart = 1
  
  var page: Int = pageStart
  var isEnded: Bool = false
  var repos: [Repo] = []
  
  mutating func update(by page: Int, repos: [Repo], isEnded: Bool) {
    if page == RepoManager.pageStart {
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
    return result.parse()
  }
  
  static func fetchForkRepos(with name: String, page: Int) async -> Repos? {
    let router = GithubRouter.forks(name, ["page": "\(page)"])
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func fetchUserRepos(with userName: String, page: Int) async -> Repos? {
    let router = GithubRouter.userRepos(userName, ["page": "\(page)"])
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func fetchRepo(with name: String) async -> Repo? {
    let router = GithubRouter.repo(name)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func userStaredRepo(with name: String) async -> StatusModel? {
    let router = GithubRouter.userStaredRepo(name)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func fetchREADME(with repoName: String) async -> Readme? {
    let router = GithubRouter.repoReadme(repoName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func starRepo(with repoName: String) async -> StatusModel? {
    let router = GithubRouter.starRepo(repoName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func unStarRepo(with repoName: String) async -> StatusModel? {
    let router = GithubRouter.unStarRepo(repoName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
}