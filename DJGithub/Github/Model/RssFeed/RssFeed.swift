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
  var id: Int
  var title: String
  var updated: String
  var content: String
  var link: String
  
  var contentEncoded: String?
  var description: String?
  var pubDate: String?
  var summary: String?

  var atomId: Int
  var feedLink: String?
  
  var unread: Bool {
    let readId = RssFeedManager.readId(with: self.atomId, feedId: self.id)
    return RssFeedManager.shared.readMapping[readId] == nil
  }
  
  enum CodingKeys: String, CodingKey {
    case id, title, updated, content, link, feedLink, pubDate,
         contentEncoded = "content:encoded", description, atomId, summary
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
    self.feedLink = try? container.decode(String.self, forKey: .feedLink)
    if let id = try? container.decode(Int.self, forKey: .id) {
      self.id = id
    } else {
      self.id = 0
    }
    self.atomId = (try? container.decode(Int.self, forKey: .atomId)) ?? 0
  }
}

extension RssFeed: SQLTable {
  static var tableName: String {
    return "rss_feed"
  }
  
  static var fields: [String] {
    return [
      "title", "updated", "content", "link", "feed_link", "atom_id"
    ]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "title": .text,
      "updated": .text,
      "content": .text,
      "link": .text,
      "feed_link": .text,
      "id": .int,
      "atom_id": .int
    ]
  }
  
  static var selectedFields: [String] {
    return [
      "id", "title", "updated", "content", "link", "feed_link", "atom_id"
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "id": self.id,
      "title": self.title,
      "updated": self.updated,
      "content": self.content,
      "link": self.link,
      "feed_link": self.feedLink ?? "",
      "atom_id": self.atomId
    ]
  }
  
  func update(with rssFeed: RssFeed) {
    guard self.id > 0 else { return }
    let title = rssFeed.title.replacingOccurrences(of: "\"", with: "'")
    let content = rssFeed.content.replacingOccurrences(of: "\"", with: "'")
    let sql = "update \(Self.tableName) set title=\"\(title)\", content=\"\(content)\", updated=\"\(rssFeed.updated)\", link=\"\(rssFeed.link)\", atom_id=\(rssFeed.atomId) where id=\(self.id)"
    do {
      try Self.update(with: sql)
    } catch {
      print("update rss feed error: \(error)")
    }
  }
  
}
extension RssFeed {
  func updateReadStatus() async {
    let readId = RssFeedManager.readId(with: self.atomId, feedId: self.id)
    if let model = RssFeedRead.get(by: atomId, feedId: self.id) {
      if model.increment() {
        RssFeedManager.shared.readMapping[readId] = model.readCount + 1
      }
    } else {
      let model = RssFeedRead(atomId: atomId, feedId: self.id)
      do {
        try model.insert()
        RssFeedManager.shared.readMapping[readId] = model.readCount + 1
      } catch {
        print("insert error: \(error)")
      }
    }
  }
}
