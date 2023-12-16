//
//  Repo.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import Foundation

struct Repo: DJCodable {
  var name: String
  var fullName: String
  var forksCount: Int
  var stargazersCount: Int
  var watchersCount: Int
  var openIssuesCount: Int
  var size: Int
  var description: String?
  var updatedAt: String
  var language: String?
  var defaultBranch: String?

  var owner: RepoOwner?
  var license: License?

  var desc: String {
    return self.description ?? "No description provided."
  }
}

extension Repo {
    var id: UUID {
        return UUID()
    }
}

struct RepoOwner: DJCodable {
  var avatarUrl: String
  var id: Int
  var login: String
  var type: String
}

struct License: DJCodable {
  var name: String
  var key: String
  var url: String?
  var spdxId: String?

  var licenseKey: String {
    return self.spdxId ?? self.key
  }
}

extension Repo {
    #if DEBUG
    static let sample = Repo(
        name: "DJGithub",
        fullName: "dyljqq/DJGithub",
        forksCount: 10,
        stargazersCount: 15,
        watchersCount: 3,
        openIssuesCount: 200,
        size: 10,
        updatedAt: "2023-02-17",
        language: "Swift",
        owner: repoOwner
    )
    
    static let repoOwner = RepoOwner(
        avatarUrl: "https://avatars.githubusercontent.com/u/8120438?v=4",
        id: 1,
        login: "dyljqq",
        type: "User"
    )
    
    #endif
}
