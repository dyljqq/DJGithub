//
//  RssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

typealias RssFeedParsable = RssFeedConvertable & DJCodable

protocol RssFeedConvertable {
  func convert() -> [RssFeed]
}

extension RssFeedConvertable {
  func convert() -> [RssFeed] {
    return []
  }
}

struct RssFeed: DJCodable {
  var id: Int?
  var title: String
  var updated: String
  var content: String
  var link: String
  
  var atomId: Int?
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
      "atom_id": .bigint
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
  
}
