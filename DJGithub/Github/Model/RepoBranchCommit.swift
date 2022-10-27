//
//  RepoBranchCommit.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/27.
//

import Foundation

struct RepoBranchCommitInfo: DJCodable {
  var commit: RepoBranchCommit
  var url: String
  var htmlUrl: String
  var commentsUrl: String
  var stats: RepoBranchCommitStats
  
  var files: [RepoBranchCommitFile]
  
  var author: RepoBranchCommitInfoUser?
  var committer: RepoBranchCommitInfoUser?
}

struct RepoBranchCommit: DJCodable {
  struct RepoBranchCommitAuthor: DJCodable {
    var name: String
    var email: String?
    var date: String
  }
  
  var message: String
  var commentCount: Int
  
  var author: RepoBranchCommitAuthor
  var committer: RepoBranchCommitAuthor
}

extension RepoBranchCommitInfo {
  struct RepoBranchCommitInfoUser: DJCodable {
    var id: Int
    var login: String
    var avatarUrl: String
  }
  
  struct RepoBranchCommitFile: DJCodable {
    var filename: String
    var status: String
    var additions: Int
    var deletions: Int
    var contentsUrl: String
    var blobUrl: String
    var patch: String
  }
  
  struct RepoBranchCommitStats: DJCodable {
    var total: Int
    var additions: Int
    var deletions: Int
  }
}
