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
  var websiteUrl: String?
  var bio: String?
  var company: String?
  var location: String?
  var createdAt: String
  var email: String?
  
  var viewerCanFollow: Bool
  var viewerIsFollowing: Bool
  var isViewer: Bool
  
  var following: TotalCountModel
  var followers: TotalCountModel
  var starredRepositories: TotalCountModel
  var repositories: TotalCountModel
  
  var pinnedItems: PinnedRepos
  var userContribution: UserContribution?
  
  var desc: String {
    return isEmpty(by: self.bio) ? "No description provided." : self.bio!
  }
}

struct PinnedRepos: DJCodable {
  var nodes: [PinnedRepoNode]
}

struct PinnedRepoNode: DJCodable {
  var name: String
  var nameWithOwner: String
  var description: String
  var owner: PinnedRepoNodeOwner
  var stargazers: TotalCountModel
  var primaryLanguage: PrimaryLanguage
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
