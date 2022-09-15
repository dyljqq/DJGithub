//
//  GithubRouter.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

enum GithubRouter: Router {
  case userInfo(String)
  
  var baseURLString: String {
    return "https://api.github.com/"
  }
  
  var path: String {
    switch self {
    case .userInfo(let name): return "users/\(name)"
    }
  }
  
  var headers: [String : String] {
    return [
      "Authorization": "token " + "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",
      "Accept": "application/vnd.github+json"
    ]
  }
  
  func asURLRequest() -> URLRequest? {
    var request = configURLRequest()
    request?.setValue(Config.shared.authorization, forHTTPHeaderField: "Authorization")
    return request
  }
}
