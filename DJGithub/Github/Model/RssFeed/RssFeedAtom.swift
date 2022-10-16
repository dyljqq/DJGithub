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
  
  var createTime: String
  var updateTime: String
  
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
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    if let title = try? container.decode(String.self, forKey: .title), !title.isEmpty {
      self.title = title
    } else {
      let title =  try? container.decode(String.self, forKey: .description)
      self.title = title ?? "No title provided."
    }
    self.title = try container.decode(String.self, forKey: .title)
    self.des = try container.decode(String.self, forKey: .des)
    self.siteLink = try container.decode(String.self, forKey: .siteLink)
    self.feedLink = try container.decode(String.self, forKey: .feedLink)
    if let createTime = try? container.decode(String.self, forKey: .createTime) {
      self.createTime = createTime
    } else {
      self.createTime = DateHelper.standard.dateToString(Date.now)
    }
    
    if let updateTime = try? container.decode(String.self, forKey: .updateTime) {
      self.updateTime = updateTime
    } else {
      self.updateTime = DateHelper.standard.dateToString(Date.now)
    }
  }
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
      "id", "title", "des", "site_link", "feed_link",
      "create_time", "update_time"
    ]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
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
  
  var fieldsValueMapping: [String : Any] {
    return [
      "title": self.title,
      "id": self.id,
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
  
  static func totalFeedsStr(with feedLink: String) -> String {
    let feeds: [RssFeed] = RssFeed.select(with: " where feed_link='\(feedLink)'")
    let totalCount = feeds.count
    let readedCount = feeds.filter { !$0.unread }.count
    return "\(readedCount)/\(totalCount)"
  }
  
  var hasFeeds: Bool {
    let feeds: [RssFeed] = RssFeed.select(with: " where feed_link='\(self.feedLink)'")
    return !feeds.isEmpty
  }
  
  static func get(by id: Int) -> RssFeedAtom? {
    let condition = " where id=\(id)"
    let atoms: [RssFeedAtom] = Self.select(with: condition)
    return atoms.first
  }
}
