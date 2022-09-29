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
  case userFollowing(queryItems: [String: String])
  case followUser(String)
  case unfollowUser(String)
  case checkFollowStatus(String)
  case stargazers(String, [String: String])
  case contributors(String, [String: String])
  case subscribers(String, [String: String])
  case forks(String, [String: String])
  
  var baseURLString: String {
    return "https://api.github.com/"
  }
  
  var method: HTTPMethod {
    switch self {
    case .userContribution: return .POST
    case .starRepo: return .PUT
    case .unStarRepo: return .DELETE
    case .followUser: return .PUT
    case .unfollowUser: return .DELETE
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
    case .userFollowing: return "user/following"
    case .followUser(let name): return "user/following/\(name)"
    case .unfollowUser(let name): return "user/following/\(name)"
    case .checkFollowStatus(let name): return "user/following/\(name)"
    case .stargazers(let name, _): return "repos/\(name)/stargazers"
    case .subscribers(let name, _): return "repos/\(name)/subscribers"
    case .contributors(let name, _): return "repos/\(name)/contributors"
    case .forks(let name, _): return "repos/\(name)/forks"
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
    
    switch self {
    case .userStartedRepos(_, let items),
        .userFollowing(let items),
        .contributors(_, let items),
        .subscribers(_, let items),
        .stargazers(_, let items),
        .forks(_, let items):
      queryItems = items
    default:
      break
    }
    var request = configURLRequest(with: queryItems)
    request?.setValue(ConfigManager.config.authorization, forHTTPHeaderField: "Authorization")
    if !parameters.isEmpty {
      switch method {
      case .POST: request?.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
      default: break
      }
    }
    return request
  }
}
