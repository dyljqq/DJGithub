//
//  Feeds.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import Foundation

struct Feeds: DJCodable {
  var currentUserUrl: String
}

struct FeedInfo: DJCodable {
  var title: String
  var updated: String
  var items: [Feed]
}

struct Feed: DJCodable {
  var id: String
  var published: String?
  var title: String?
  var content: String
}
