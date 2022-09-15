//
//  UserRequest.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct UserViewModel {
  static func getUser(with name: String) async -> User? {
    let router = GithubRouter.userInfo(name)
    let result = await APIClient.shared.get(router: router)
    return result.parse()
  }
  
}
