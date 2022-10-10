//
//  Feeds.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import Foundation

enum FeedPushType {
  case repo(String)
  case webview(String)
}

enum FeedActionType {
  case starred, forked, createdRepository
}

struct Feeds: DJCodable {
  var currentUserUrl: String
}

struct FeedInfo: DJCodable {
  var title: String
  var updated: String
  var entry: [Feed]
}

struct Feed: DJCodable {
  var id: String
  var published: String?
  var title: String?
  var content: String
  var author: FeedAuthor?
  var thumbnail: FeedAuthorThumbnail?
  var link: FeedLink?
  
  // TODO
  var pushType: FeedPushType {
    return .repo("")
  }
  
  enum CodingKeys: String, CodingKey {
    case id, published, title, content, author, thumbnail = "media:thumbnail"
  }
}

struct FeedAuthor: DJCodable {
  var name: String
  var email: String?
  var uri: String?
}

struct FeedAuthorThumbnail: DJCodable {
  var url: String?
  var width: String?
  var height: String?
}

struct FeedLink: DJCodable {
  var type: String
  var href: String
}
