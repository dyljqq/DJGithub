//
//  RepoPullFile.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/28.
//

import Foundation

struct RepoPullFile: DJCodable {
  var filename: String
  var status: String
  var additions: Int
  var deletions: Int
  var contentsUrl: String
  var blobUrl: String
  var patch: String?
}
