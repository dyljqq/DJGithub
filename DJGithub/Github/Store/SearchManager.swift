//
//  SearchManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/1.
//

import Foundation

struct SearchManager {
  
  static func searchUsers(with query: String, page: Int) async -> SearchList<UserFollowing>? {
    return await self.search(with: query, searchType: .users, page: page)
  }
  
  static func searchRepos(with query: String, page: Int) async -> SearchList<Repo>? {
    return await self.search(with: query, searchType: .repos, page: page)
  }
  
  static func search<T: DJCodable>(with query: String, searchType: SearchType, page: Int) async -> T? {
    guard !query.isEmpty else { return nil }
    let params = [
      "q": query,
      "page": "\(page)"
    ]
    let router: GithubRouter
    switch searchType {
    case .repos: router = GithubRouter.searchRepos(params)
    case .users: router = GithubRouter.searchUser(params)
    }
    let result = await APIClient.shared.get(by: router)
    return result.parse() as T?
  }
  
}
