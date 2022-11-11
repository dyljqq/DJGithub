//
//  UserViewer.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/25.
//

import Foundation

struct UserViewer: DJCodable {
  var name: String?
  var login: String
  var avatarUrl: String

  @Default<String.Blog> var websiteUrl: String
  @Default<String.UnProvidedDesc> var bio: String
  @Default<String.Company> var company: String
  @Default<String.Location> var location: String
  @Default<String.Email> var email: String

  var createdAt: String
  
  @Default<Bool.False> var viewerCanFollow: Bool
  @Default<Bool.False> var viewerIsFollowing: Bool
  @Default<Bool.False> var isViewer: Bool
  
  var following: TotalCountModel
  var followers: TotalCountModel
  var starredRepositories: TotalCountModel
  var repositories: TotalCountModel
  
  var pinnedItems: PinnedRepos
  var userContribution: UserContribution?
}

struct PinnedRepos: DJCodable {
  var nodes: [PinnedRepoNode]
}

struct PinnedRepoNode: DJCodable {
  var name: String
  var nameWithOwner: String
  var description: String?
  var viewerHasStarred: Bool
  var owner: PinnedRepoNodeOwner
  var stargazers: TotalCountModel
  var primaryLanguage: PrimaryLanguage?
}

extension PinnedRepoNode {
  struct PinnedRepoNodeOwner: DJCodable {
    var avatarUrl: String
  }
}

struct PrimaryLanguage: DJCodable {
  var name: String
  var color: String
}

struct TotalCountModel: DJCodable {
  var totalCount: Int
}
