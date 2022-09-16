//
//  GithubRouter.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

enum GithubRouter: Router {
  case userInfo(String)
  case userContribution(String)
  case userStartedRepos(String)
  
  var baseURLString: String {
    return "https://api.github.com/"
  }
  
  var method: HTTPMethod {
    switch self {
    case .userContribution: return .POST
    default: return .GET
    }
  }
  
  var path: String {
    switch self {
    case .userInfo(let name): return "users/\(name)"
    case .userContribution: return "graphql"
    case .userStartedRepos(let name): return "users/\(name)/starred"
    }
  }
  
  var headers: [String : String] {
    return [
      "Accept": "application/vnd.github+json"
    ]
  }
  
  var parameters: [String : Any] {
    switch self {
    case .userContribution(let name):
      let query = """
query {
  user(login: "\(name)") {
    name
    contributionsCollection {
      contributionCalendar {
        colors
        totalContributions
        weeks {
          contributionDays {
            color
            contributionCount
            date
            weekday
          }
          firstDay
        }
      }
    }
  }
}
"""
      return ["query": query]
    default: return [:]
    }
  }
  
  func asURLRequest() -> URLRequest? {
    var request = configURLRequest()
    request?.setValue(Config.shared.authorization, forHTTPHeaderField: "Authorization")
    if !parameters.isEmpty {
      request?.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    }
    return request
  }
}
