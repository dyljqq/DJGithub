//
//  RepoContent.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import Foundation

struct RepoContent: DJCodable {
  enum RepoContentType: String, DJCodable {
    case file, dir
  }

  var name: String
  var path: String
  var size: Int
  var url: String
  var content: String?
  var downloadUrl: String?
  var type: RepoContentType

  var deepLength: Int = 0
  var isExpanded: Bool = false
  var contents: [RepoContent] = []

  enum CodingKeys: String, CodingKey {
    case name, path, size, url, downloadUrl, type, content
  }

  var isDir: Bool {
    if case RepoContentType.dir = self.type {
      return true
    }
    return false
  }
}

struct RepoContents: DJCodable {
  var items: [RepoContent]
}
