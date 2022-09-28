//
//  UserManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import Foundation

struct UserFollowing: Decodable {
  var id: Int
  var login: String
  var url: String
  var avatarUrl: String
  
  var isFollowing: Bool = false
  
  enum CodingKeys: String, CodingKey {
    case id, login, url, avatarUrl
  }
  
  mutating func update(isFollowing: Bool) {
    self.isFollowing = isFollowing
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
  static func getUserFollowing(with page: Int = 1) async -> [UserFollowing] {
    let router = GithubRouter.userFollowing(queryItems: ["page": "\(page)"])
    let result = await APIClient.shared.get(by: router)
    switch result {
    case.success(let d):
      if let items = d["items"] as? [Any] {
        let users = DJDecoder<[UserFollowing]>(value: items).decode() ?? []
        return users.map { user in
          var user = user
          user.update(isFollowing: true)
          return user
        }
      }
    case .failure:
      break
    }
    return []
  }
  
  static func followUser(with userName: String) async -> StatusModel? {
    let router = GithubRouter.followUser(userName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func unFollowUser(with userName: String) async -> StatusModel? {
    let router = GithubRouter.unfollowUser(userName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func checkFollowStatus(with userName: String) async -> StatusModel? {
    let router = GithubRouter.checkFollowStatus(userName)
    let result = await APIClient.shared.get(by: router)
    return result.parse()
  }
  
  static func loadLocalDevelopers() -> [LocalDeveloperGroup] {
    return loadBundleJSONFile("developers.json")
  }
  
}
