//
//  RepoBranch.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/27.
//

import Foundation

struct RepoBranch: DJCodable {
  struct RepoBranchCommit: DJCodable {
    var sha: String
    var url: String
  }
  
  var name: String
  var protected: Bool
  
  var commit: RepoBranchCommit
}
