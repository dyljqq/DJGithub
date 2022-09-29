//
//  LocalDeveloperGroup.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import Foundation

struct LocalDeveloperGroup: Decodable {
  var name: String
  var id: Int
  var users: [LocalDeveloper]
}

struct LocalDeveloper: Decodable {
  var id: String
  var des: String?
}
