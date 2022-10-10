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
  
  var formatedDate: String? {
    guard let published = published,
          let date = FeedDateParser.date(from: published)else {
      return published
    }
    let diff = (Date.now.timeIntervalSince1970 - date.timeIntervalSince1970)
    if diff < 60 {
      return "\(diff) seconds ago"
    } else if diff >= 60 && diff < 3600 {
      return "\(Int(diff / 60)) minuts ago"
    } else if diff >= 3600 && diff < 24 * 3600 {
      return "\(Int(diff / 3600)) hours ago"
    } else if diff >= 24 * 3600 && diff <= 24 * 30 * 3600 {
      return "\(Int(diff / (24 * 3600))) days ago"
    } else if diff >= (24 * 30 * 3600) && diff < (12 * 30 * 24 * 30 * 3600) {
      return "\(Int(diff / (30 * 24 * 3600))) months ago"
    } else {
      if let published = published.components(separatedBy: "T").first {
        return published
      }
    }
    return published
  }
  
  var eventName: String? {
    return RegularParser.parse(with: ":([a-zA-Z]+)Event", validateString: self.id).first
  }
  
  // TODO
  var pushType: FeedPushType {
    return .repo("")
  }
  
  enum CodingKeys: String, CodingKey {
    case id, published, title, content, author, thumbnail = "media:thumbnail", link
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
  var type: String?
  var href: String?
  
  var path: String? {
    guard let href = href else { return nil }
    if var path = URLComponents(string: href)?.path {
      if path.starts(with: "/") {
        path.removeFirst()
      }
      return path
    }
    return nil
  }
}
