//
//  UserManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import Foundation

struct UserFollowings: Decodable {
  var items: [UserFollowing]
}

struct UserFollowing: Decodable {
  var id: Int
  var login: String
  var url: String
  var avatarUrl: String
  
  var followingStatus: UserFollowingStatus = .unknown
  
  enum CodingKeys: String, CodingKey {
    case id, login, url, avatarUrl
  }
}

struct UserManager {
  
  /**
   "avatar_url" = "https://avatars.githubusercontent.com/u/2971?v=4";
   "events_url" = "https://api.github.com/users/rentzsch/events{/privacy}";
   "followers_url" = "https://api.github.com/users/rentzsch/followers";
   "following_url" = "https://api.github.com/users/rentzsch/following{/other_user}";
   "gists_url" = "https://api.github.com/users/rentzsch/gists{/gist_id}";
   "gravatar_id" = "";
   "html_url" = "https://github.com/rentzsch";
   id = 2971;
   login = rentzsch;
   "node_id" = "MDQ6VXNlcjI5NzE=";
   "organizations_url" = "https://api.github.com/users/rentzsch/orgs";
   "received_events_url" = "https://api.github.com/users/rentzsch/received_events";
   "repos_url" = "https://api.github.com/users/rentzsch/repos";
   "site_admin" = 0;
   "starred_url" = "https://api.github.com/users/rentzsch/starred{/owner}{/repo}";
   "subscriptions_url" = "https://api.github.com/users/rentzsch/subscriptions";
   type = User;
   url = "https://api.github.com/users/rentzsch";
   */
  static func getUserFollowing(with userName: String, page: Int = 1, perpage: Int = 30) async -> [UserFollowing] {
    let router = GithubRouter.userFollowing(userName, queryItems: ["page": "\(page)", "per_page": "\(perpage)"])
    let result = await APIClient.shared.get(by: router)
    let users: UserFollowings? = result.parse()
    return users?.items ?? []
  }
  
  static func getUserFollowers(with userName: String, page: Int = 1) async -> [UserFollowing] {
    let router = GithubRouter.userFollowers(userName, ["page": "\(page)"])
    let result = await APIClient.shared.get(by: router)
    let users: UserFollowings? = result.parse()
    return users?.items ?? []
  }
  
  static func getUserSubscription(with userName: String, page: Int = 1) async -> Repos? {
    let router = GithubRouter.userSubscription(userName, ["page": "\(page)"])
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func followUser(with userName: String) async -> StatusModel? {
    let router = GithubRouter.followUser(userName)
    let result = await APIClient.shared.get(by: router)
    let status: StatusModel? = result.parse()
    
    // sync follow status
    if let status = status, status.isStatus204 {
      await UserFollowingManager.shared.update(with: userName, following: true)
    }
    return status
  }
  
  static func unFollowUser(with userName: String) async -> StatusModel? {
    let router = GithubRouter.unfollowUser(userName)
    let result = await APIClient.shared.get(by: router)
    let status: StatusModel? = result.parse()
    if let status = status, status.isStatus204 {
      await UserFollowingManager.shared.update(with: userName, following: false)
    }
    return status
  }
  
  static func checkFollowStatus(with userName: String) async -> StatusModel? {
    let router = GithubRouter.checkFollowStatus(userName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func loadLocalDevelopers(completionHandler: @escaping ([LocalDeveloperGroup]) -> ()) {
    DispatchQueue.global().async {
      let rs: [LocalDeveloperGroup] = loadBundleJSONFile("developers.json")
      DispatchQueue.main.async {
        completionHandler(rs)
      }
    }
  }
  
  static func loadLocalDevelopersAsync() async throws -> [LocalDeveloperGroup] {
    try await withCheckedThrowingContinuation { continuation in
      loadLocalDevelopers { groups in
        continuation.resume(returning: groups)
      }
    }
  }
  
  static func fetch(by router: GithubRouter) async -> [UserFollowing] {
    let result = await APIClient.shared.get(by: router)
    let users: UserFollowings? = result.parse()
    return users?.items ?? []
  }
  
  static func getUser(with name: String) async -> User? {
    let router = GithubRouter.userInfo(name)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func fetchUserContributions(with name: String) async -> UserContribution? {
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
    let router = GithubRouter.userContribution(parameters: ["query": query])
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
