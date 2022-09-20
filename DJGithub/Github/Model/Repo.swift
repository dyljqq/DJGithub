//
//  Repo.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/16.
//

import Foundation

struct Repos: Decodable {
  var items: [Repo]
}

struct Repo: Decodable {
  var fullName: String
  var forksCount: Int
  var stargazersCount: Int
  var description: String?
  var updatedAt: String
  var language: String?
  
  var owner: RepoOwner?
  
  var desc: String {
    return self.description ?? "No description provided."
  }
}

struct RepoOwner: Decodable {
  var avatarUrl: String
  var id: Int
  var login: String
  var type: String
}
