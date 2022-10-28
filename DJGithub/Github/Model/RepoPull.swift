//
//  RepoPull.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/28.
//

import Foundation

struct RepoPull: DJCodable {
  var id: Int
  var number: Int
  var state: String
  var title: String
  var body: String?
  var createdAt: String
  var updatedAt: String
  
  var merged: Bool
  var mergeable: Bool?
  var mergedBy: UserFollowing?
  var commits: Int
  var additions: Int
  var deletions: Int
  var changedFiles: Int
  
  var user: UserFollowing
  var head: RepoPullBranch
  var base: RepoPullBranch
  
  var desc: String {
    return self.body ?? ""
  }
}

extension RepoPull {
  struct RepoPullBranch: DJCodable {
    var label: String
    var ref: String
    var sha: String
    var user: UserFollowing
  }
}
