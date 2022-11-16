//
//  LocalRssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

struct RssFeedAtom: DJCodable {
  var id: Int
  @Default<String.UnProviedTitle> var title: String
  @Default<String.UnProvidedDesc> var des: String
  var siteLink: String
  var feedLink: String

  @Default<String.Now> var createTime: String
  @Default<String.Now> var updateTime: String

  var description: String?

  init(title: String, desc: String, feedLink: String) {
    self.title = title
    self.des = desc
    self.feedLink = feedLink

    self.siteLink = ""
    self.id = 0
    self.createTime = ""
    self.updateTime = ""
  }
}

extension RssFeedAtom: SQLTable {
  static var tableName: String {
    return "rss_feed_atom"
  }

  static var fields: [String] {
    return [
      "title", "des", "site_link", "feed_link",
      "create_time", "update_time"
    ]
  }

  static var fieldsTypeMapping: [String: FieldType] {
    return [
      "id": .bigint,
      "title": .text,
      "des": .text,
      "site_link": .text,
      "feed_link": .text,
      "create_time": .text,
      "update_time": .text
    ]
  }

  static var selectedFields: [String] {
    return [
      "id", "title", "des", "site_link", "feed_link", "create_time", "update_time"
    ]
  }

  var fieldsValueMapping: [String: Any] {
    return [
      "title": self.title,
      "des": self.des,
      "site_link": self.siteLink,
      "feed_link": self.feedLink,
      "create_time": self.createTime,
      "update_time": self.updateTime
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

  static func get(by id: Int) -> RssFeedAtom? {
    let condition = " where id=\(id)"
    let atoms: [RssFeedAtom] = Self.select(with: condition)
    return atoms.first
  }
}
