//
//  SearchManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/1.
//

import Foundation

struct SearchManager {
  
  static func searchUsers(with query: String, page: Int) async -> SearchList<UserFollowing>? {
    let params = [
      "q": query,
      "page": "\(page)"
    ]
    let router = GithubRouter.searchUser(params)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func searchRepos(with query: String, page: Int) async -> SearchList<Repo>? {
    let params = [
      "q": query,
      "page": "\(page)"
    ]
    let router = GithubRouter.searchRepos(params)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
}
