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
