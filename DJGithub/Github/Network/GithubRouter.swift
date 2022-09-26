//
//  GithubRouter.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

enum GithubRouter: Router {
  
  case userInfo(String)
  case userContribution(parameters: [String: Any])
  case userStartedRepos(path: String, queryItems: [String: String])
  case repo(String)
  case userStaredRepo(String)
  case repoReadme(String)
  case starRepo(String)
  case unStarRepo(String)
  
  var baseURLString: String {
    return "https://api.github.com/"
  }
  
  var method: HTTPMethod {
    switch self {
    case .userContribution: return .POST
    case .starRepo: return .PUT
    case .unStarRepo: return .DELETE
    default: return .GET
    }
  }
  
  var path: String {
    switch self {
    case .userInfo(let name): return "users/\(name)"
    case .userContribution: return "graphql"
    case .userStartedRepos(let name, _): return "users/\(name)/starred"
    case .repo(let name): return "repos/\(name)"
    case .userStaredRepo(let name): return "user/starred/\(name)"
    case .repoReadme(let name): return "repos/\(name)/readme"
    case .starRepo(let name): return "user/starred/\(name)"
    case .unStarRepo(let name): return "user/starred/\(name)"
    }
  }
  
  var headers: [String : String] {
    return [
      "Accept": "application/vnd.github+json"
    ]
  }
  
  var parameters: [String : Any] {
    switch self {
    case .userContribution(let params):
      return params
    case .userStartedRepos(_, let queryItems):
      return queryItems
    default: return [:]
    }
  }
  
  func asURLRequest() -> URLRequest? {
    var queryItems: [String: String] = [:]
    if case GithubRouter.userStartedRepos(_, let items) = self {
      queryItems = items
    }
    var request = configURLRequest(with: queryItems)
    request?.setValue(Config.shared.authorization, forHTTPHeaderField: "Authorization")
    if !parameters.isEmpty {
      switch method {
      case .POST: request?.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
      default: break
      }
    }
    return request
  }
}
