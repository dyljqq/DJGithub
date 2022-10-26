//
//  Repository.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/26.
//

import Foundation

struct Repository: DJCodable {
  var url: String
  var name: String
  var nameWithOwner: String
  var description: String?
  var createdAt: String
  var updatedAt: String
  var owner: RepositoryOwner?

  var isPrivate: Bool
  var viewerHasStarred: Bool
  
  var forkCount: Int
  var diskUsage: Int

  var stargazers: TotalCountModel
  var watchers: TotalCountModel
  var issues: TotalCountModel
  var pullRequests: TotalCountModel
  var primaryLanguage: PrimaryLanguage?
  
  var licenseInfo: LicenseInfo?
  var languages: RepositotyLanguage?
  var defaultBranchRef: DefaultBranchRef?
  
  var desc: String {
    return self.description ?? "No description provided."
  }
  
  struct RepositoryOwner: DJCodable {
    var login: String
    var avatarUrl: String
  }
  
  struct LicenseInfo: DJCodable {
    var spdxId: String
  }
  
  struct RepositotyLanguage: DJCodable {
    struct RepositotyLanguageEdge: DJCodable {
      struct RepositoryLanguageNode: DJCodable {
        var name: String?
        var color: String?
      }
      
      var size: Int
      var node: RepositoryLanguageNode?
    }
    var totalSize: Int
    var edges: [RepositotyLanguageEdge]?
  }
  
  struct DefaultBranchRef: DJCodable {
    struct DefaultBranchRefTarget: DJCodable {
      var history: TotalCountModel
    }
    
    var name: String
    var target: DefaultBranchRefTarget
  }
}

extension Repository.RepositotyLanguage {
  func primaryPercent(with languageName: String) -> CGFloat {
    var primarySize: CGFloat = 0
    for edge in (edges ?? []) {
      if let node = edge.node, node.name == languageName {
        primarySize = CGFloat(edge.size)
      }
    }
    return primarySize / CGFloat(totalSize)
  }
}
