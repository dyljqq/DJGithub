//
//  RssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

struct RssFeedInfo: DJCodable {
  var title: String
  var updated: String
  var link: String
  var entries: [RssFeed]
  
  var lastBuildDate: String?
  var item: [RssFeed]?
  var entry: [RssFeed]?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.title = try container.decode(String.self, forKey: .title)
    
    var dateString = ""
    if let updated = try? container.decode(String.self, forKey: .updated) {
      dateString = updated
    } else if let updated = try? container.decode(String.self, forKey: .lastBuildDate) {
      dateString = updated
    }
    
    if !dateString.isEmpty, let date = DateHelper.standard.dateFromRFC822String(dateString) {
      self.updated = DateHelper.standard.dateToString(date)
    } else {
      self.updated = dateString
    }
    
    if let link = try? container.decode(String.self, forKey: .link) {
      self.link = link
    } else {
      self.link = ""
    }
    
    if let entries = try? container.decode([RssFeed].self, forKey: .entry) {
      self.entries = entries
    } else if let entries = try? container.decode([RssFeed].self, forKey: .item) {
      self.entries = entries
    } else {
      self.entries = []
    }
  }
}

struct RssFeedLink: DJCodable {
  var href: String?
}

struct RssFeed: DJCodable {
  var id: Int?
  var title: String
  var updated: String
  var content: String
  var link: String
  
  var contentEncoded: String?
  var description: String?
  var pubDate: String?
  var summary: String?

  var rssFeedLink: RssFeedLink?
  
  var atomId: Int?
  
  enum CodingKeys: String, CodingKey {
    case id, title, updated, content, link, atomId, pubDate,
         contentEncoded = "content:encoded", description, rssFeedLink, summary
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.title = try container.decode(String.self, forKey: .title)
    
    var dateString = ""
    if let updated = try? container.decode(String.self, forKey: .updated) {
      dateString = updated
    } else if let pubDate = try? container.decode(String.self, forKey: .pubDate) {
      dateString = pubDate
    }
    
    if !dateString.isEmpty, let date = DateHelper.standard.dateFromRFC822String(dateString) {
      self.updated = DateHelper.standard.dateToString(date)
    } else {
      self.updated = dateString
    }
    
    if let link = try? container.decode(String.self, forKey: .link) {
      self.link = link
    } else if let rssFeedLink = try? container.decode(RssFeedLink.self, forKey: .rssFeedLink) {
      self.rssFeedLink = rssFeedLink
      self.link = rssFeedLink.href ?? ""
    } else {
      self.link = ""
    }
    
    if let content = try? container.decode(String.self, forKey: .content) {
      self.content = content
    } else if let content = try? container.decode(String.self, forKey: .contentEncoded) {
      self.content = content
    } else if let content = try? container.decode(String.self, forKey: .description) {
      self.content = content
    } else if let content = try? container.decode(String.self, forKey: .summary) {
      self.content = content
    } else {
      self.content = ""
    }
    self.atomId = try? container.decode(Int.self, forKey: .atomId)
    self.id = try? container.decode(Int.self, forKey: .id)
  }
}

extension RssFeed: SQLTable {
  static var tableName: String {
    return "rss_feed"
  }
  
  static var fields: [String] {
    return [
      "title", "updated", "content", "link", "atom_id"
    ]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "title": .text,
      "updated": .text,
      "content": .text,
      "link": .text,
      "atom_id": .bigint,
      "id": .int
    ]
  }
  
  static var selectedFields: [String] {
    return [
      "id", "title", "updated", "content", "link", "atom_id"
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "id": self.id ?? 0,
      "title": self.title,
      "updated": self.updated,
      "content": self.content,
      "link": self.link,
      "atom_id": self.atomId ?? 0
    ]
  }
  
  func update(with rssFeed: RssFeed) {
    guard let rssFeedId = self.id, rssFeedId > 0 else { return }
    let sql = "update \(Self.tableName) set title=\"\(rssFeed.title)\", content=\"\(rssFeed.content)\", updated=\"\(rssFeed.updated)\", link=\"\(rssFeed.link)\" where id=\(rssFeedId)"
    store?.execute(.update, sql: sql, type: RssFeed.self)
  }
  
}
