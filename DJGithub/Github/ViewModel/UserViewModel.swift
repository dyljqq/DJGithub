//
//  UserRequest.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation
import AVFoundation

struct UserViewModel {
  static func getUser(with name: String) async -> User? {
    let router = GithubRouter.userInfo(name)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func fetchUserContributions(with name: String) async -> UserContribution? {
    let router = GithubRouter.userContribution(name)
    let result = await APIClient.shared.get(by: router)
    switch result {
    case .success(let d):
      guard let data = d["data"] as? [String: Any],
            let user = data["user"] as? [String: Any],
            let contributionsCollection = user["contributionsCollection"] as? [String: Any],
            let contributionCalendar = contributionsCollection["contributionCalendar"] as? [String: Any] else {
        return nil
      }
      return UserContribution(with: contributionCalendar)
    case .failure(let error):
      print("fetchUserContributions error: \(error)")
    }
    return nil
  }
}
