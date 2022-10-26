//
//  UserManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import Foundation

struct UserFollowings: DJCodable {
  var items: [UserFollowing]
}

struct UserFollowing: DJCodable {
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
    let userFollowings = try? await APIClient.shared.model(with: router) as [UserFollowing]?
    return userFollowings ?? []
  }
  
  static func getUserFollowers(with userName: String, page: Int = 1) async -> [UserFollowing] {
    let router = GithubRouter.userFollowers(userName, ["page": "\(page)"])
    let userFollowers = try? await APIClient.shared.model(with: router) as [UserFollowing]?
    return userFollowers ?? []
  }
  
  static func getUserSubscription(with userName: String, page: Int = 1) async -> [Repo] {
    let router = GithubRouter.userSubscription(userName, ["page": "\(page)"])
    let repos = try? await APIClient.shared.model(with: router) as [Repo]?
    return repos ?? []
  }
  
  static func followUser(with userName: String) async -> StatusModel? {
    let router = GithubRouter.followUser(userName)
    let status = try? await APIClient.shared.model(with: router) as StatusModel?
    
    // sync follow status
    if let status = status, status.isStatus204 {
      await UserFollowingManager.shared.update(with: userName, following: true)
    }
    return status
  }
  
  static func unFollowUser(with userName: String) async -> StatusModel? {
    let router = GithubRouter.unfollowUser(userName)
    let status: StatusModel? = try? await APIClient.shared.model(with: router) as StatusModel?
    if let status = status, status.isStatus204 {
      await UserFollowingManager.shared.update(with: userName, following: false)
    }
    return status
  }
  
  static func checkFollowStatus(with userName: String) async -> StatusModel? {
    let router = GithubRouter.checkFollowStatus(userName)
    return try? await APIClient.shared.model(with: router)
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
    return (try? await APIClient.shared.model(with: router) as [UserFollowing]?) ?? []
  }
  
  static func getUser(with name: String) async -> User? {
    let router = GithubRouter.userInfo(name)
    return try? await APIClient.shared.model(with: router)
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
    do {
      let data: Data = try await APIClient.shared.data(with: router)
      guard let d = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
           let data = d["data"] as? [String: Any],
           let user = data["user"] as? [String: Any],
           let contributionsCollection = user["contributionsCollection"] as? [String: Any],
           let contributionCalendar = contributionsCollection["contributionCalendar"] as? [String: Any] else {
        return nil
      }
      return UserContribution(with: contributionCalendar)
    } catch {
      print("fetchUserContributions error: \(error)")
    }
    return nil
  }
  
  static func editUserInfo(with params: [String: String]) async -> User? {
    let router = GithubRouter.userInfoEdit(params: params)
    return try? await APIClient.shared.model(with: router)
  }
  
  static func fetchUserInfo(by userName: String? = nil) async -> UserViewer? {
    let query: String
    let key: String
    if let userName = userName {
      key = "user"
      query = """
   query {\n      organization(login: \"\(userName)\") {\n        __typename\n        databaseId\n        name\n        login\n        avatarUrl\n        email\n        location\n        description\n        createdAt\n        websiteUrl\n        pinnableItems {\n          totalCount\n        }\n        membersWithRole {\n          totalCount\n        }\n        pinnedItems(first: 6) {\n          nodes {\n            ...RepositoryDetails\n          }\n        }\n      }\n      user(login: \"\(userName)\") {\n        __typename\n        databaseId\n        name\n        login\n        avatarUrl\n        websiteUrl\n        bio\n        company\n        email\n        location\n        createdAt\n        viewerCanFollow\n        viewerIsFollowing\n        isViewer\n        status {\n          emoji\n          message\n          indicatesLimitedAvailability\n        }\n        followers {\n          totalCount\n        }\n        following {\n          totalCount\n        }\n        starredRepositories {\n          totalCount\n        }\n        repositories(ownerAffiliations: [OWNER]) {\n          totalCount\n        }\n        pinnedItems(first: 6) {\n          nodes {\n            ...RepositoryDetails\n          }\n        }\n        organizations(first: 10) {\n          nodes {\n            name\n            login\n            avatarUrl\n            ... on Organization {\n              description\n            }\n          }\n        }\n        contributionsCollection {\n          contributionCalendar {\n     colors\n       totalContributions\n            weeks {\n              contributionDays {\n                date\n                contributionCount\n                weekday\n    color\n          }\n            }\n          }\n        }\n      }\n    }\n\n    fragment RepositoryDetails on Repository {\n      name\n      nameWithOwner\n      description\n      owner {\n        avatarUrl\n      }\n      updatedAt\n      viewerHasStarred\n      primaryLanguage {\n        name\n        color\n      }\n      stargazers {\n        totalCount\n      }\n    }
"""
    } else {
      key = "viewer"
      query = """
query {\n      organization(login: \"\") {\n        __typename\n        databaseId\n        name\n        login\n        avatarUrl\n        email\n        location\n        description\n        createdAt\n        websiteUrl\n        pinnableItems {\n          totalCount\n        }\n        membersWithRole {\n          totalCount\n        }\n        pinnedItems(first: 6) {\n          nodes {\n            ...RepositoryDetails\n          }\n        }\n      }\n      viewer {\n        __typename\n        databaseId\n        name\n        login\n        avatarUrl\n        websiteUrl\n        bio\n        company\n        email\n        location\n        createdAt\n        viewerCanFollow\n        viewerIsFollowing\n        isViewer\n        status {\n          emoji\n          message\n          indicatesLimitedAvailability\n        }\n        followers {\n          totalCount\n        }\n        following {\n          totalCount\n        }\n        starredRepositories {\n          totalCount\n        }\n        repositories(ownerAffiliations: [OWNER]) {\n          totalCount\n        }\n        pinnedItems(first: 6) {\n          nodes {\n            ...RepositoryDetails\n          }\n        }\n        organizations(first: 10) {\n          nodes {\n            name\n            login\n            avatarUrl\n            ... on Organization {\n              description\n            }\n          }\n        }\n        contributionsCollection {\n          contributionCalendar {\n colors\n            totalContributions\n            weeks {\n              contributionDays {\n                date\n                contributionCount\n                weekday\n   color\n           }\n            }\n          }\n        }\n      }\n    }\n\n    fragment RepositoryDetails on Repository {\n      name\n      nameWithOwner\n      description\n      owner {\n        avatarUrl\n      }\n      updatedAt\n      viewerHasStarred\n      primaryLanguage {\n        name\n        color\n      }\n      stargazers {\n        totalCount\n      }\n    }
"""
    }
    let router = GithubRouter.userContribution(parameters: ["query": query])
    do {
      let data: Data = try await APIClient.shared.data(with: router)
      guard let d = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
      let data = d["data"] as? [String: Any],
      let viewer = data[key] as? [String: Any] else { return nil }
      
      var userViewer: UserViewer? = try DJDecoder(dict: viewer).decode()
      if let contributionsCollection = viewer["contributionsCollection"] as? [String: Any],
         let contributionCalendar = contributionsCollection["contributionCalendar"] as? [String: Any] {
        let userContribution = UserContribution(with: contributionCalendar)
        userViewer?.userContribution = userContribution
      }
      return userViewer
    } catch {
      print("error: \(error)")
    }
    return nil
  }
  
}
