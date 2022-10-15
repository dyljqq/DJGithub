//
//  LocalRssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

struct RssFeedAtom: DJCodable {
  var id: Int
  var title: String
  var des: String
  var siteLink: String
  var feedLink: String
  
  var createTime: String?
  var updateTime: String?
}

extension RssFeedAtom: SQLTable {
  static var tableName: String {
    return "rss_feed_atom"
  }
  
  static var needFieldId: Bool {
    return false
  }
  
  static var fields: [String] {
    return [
      "id", "title", "des", "site_link", "feed_link"
    ]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "id": .bigint,
      "title": .text,
      "des": .text,
      "site_link": .text,
      "feed_link": .text,
      "atom_type": .text
    ]
  }
  
  static var selectedFields: [String] {
    return [
      "id", "title", "des", "site_link", "feed_link"
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "title": self.title,
      "id": self.id,
      "des": self.des,
      "site_link": self.siteLink,
      "feed_link": self.feedLink,
    ]
  }
  
}

extension RssFeedAtom {
  static func getByFeedLink(_ feedLink: String) -> RssFeedAtom? {
    let condition = " where feed_link='\(feedLink)'"
    let atoms: [RssFeedAtom] = Self.select(with: condition)
    return atoms.first
  }
  
  static func isExistedByFeedLink(_ feedLink: String) -> Bool {
    return getByFeedLink(feedLink) != nil
  }
  
  var hasFeeds: Bool {
    let feeds: [RssFeed] = RssFeed.select(with: " where atom_id=\(self.id)")
    return !feeds.isEmpty
  }
}
