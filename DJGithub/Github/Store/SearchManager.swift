//
//  SearchManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/1.
//

import Foundation

struct SearchCondition {
  let query: String
  let sort: String
  let order: String
  var page: Int
  let perPage: Int

  var params: [String: String] {
    return [
      "q": query,
      "sort": sort,
      "order": order,
      "page": "\(page)",
      "per_page": "\(perPage)"
    ]
  }

  init(query: String, sort: String = "", order: String = "desc", page: Int = 1, perPage: Int = 20) {
    self.query = query
    self.sort = sort
    self.order = order
    self.page = page
    self.perPage = perPage
  }

  mutating func update(with page: Int) {
    self.page = page
  }
}

struct SearchManager {

  static func searchUsers(with query: String, page: Int) async -> SearchList<UserFollowing>? {
    return await self.search(with: query, searchType: .users, page: page)
  }

  static func searchRepos(with query: String, page: Int) async -> SearchList<Repo>? {
    return await self.search(with: query, searchType: .repos, page: page)
  }

  static func searchUsers(with type: SearchType, condition: SearchCondition) async -> SearchList<UserFollowing>? {
    return await self.search(with: type, condition: condition)
  }

  static func searchRepos(with type: SearchType, condition: SearchCondition) async -> SearchList<Repo>? {
    return await self.search(with: type, condition: condition)
  }

  static func search<T: DJCodable>(with type: SearchType, condition: SearchCondition) async -> T? {
    guard !condition.query.isEmpty else { return nil }
    return await search(with: type, params: condition.params)
  }

  static func search<T: DJCodable>(with type: SearchType, params: [String: String]) async -> T? {
    let router: GithubRouter
    switch type {
    case .repos: router = GithubRouter.searchRepos(params)
    case .users: router = GithubRouter.searchUser(params)
    }
    return try? await APIClient.shared.model(with: router)
  }

  static func search<T: DJCodable>(with query: String, searchType: SearchType, page: Int) async -> T? {
    guard !query.isEmpty else { return nil }
    let params = [
      "q": query,
      "page": "\(page)"
    ]
    return await search(with: searchType, params: params)
  }

}
