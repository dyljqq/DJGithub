//
//  LocalRepo.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/7.
//

import Foundation

struct LocalRepoGroup: DJCodable {
  var name: String
  var id: Int
  var repos: [LocalRepo]
}

struct LocalRepo: DJCodable {
  var id: String
  var des: String?
  var groupId: Int?

  var description: String {
    return self.des ?? "No description provided."
  }

  enum CodingKeys: String, CodingKey {
    case id, des
  }
}
