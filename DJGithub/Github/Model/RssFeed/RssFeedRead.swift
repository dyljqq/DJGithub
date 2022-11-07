//
//  RssFeedAtomMapping.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/2.
//

import Foundation

struct RssFeedRead: DJCodable {
  let id: Int
  let atomId: Int
  let feedId: Int
  let readCount: Int
  
  var unread: Bool {
    return readCount == 0
  }
  
  init(atomId: Int, feedId: Int, readCount: Int = 0) {
    self.id = 0
    self.atomId = atomId
    self.feedId = feedId
    self.readCount = readCount
  }
}

extension RssFeedRead: SQLTable {
  static var tableName: String {
    return "rss_feed_read"
  }
  
  static var fields: [String] {
    return [
      "atom_id", "feed_id", "read_count"
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "atom_id": self.atomId,
      "feed_id": self.feedId,
      "read_count": self.readCount
    ]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "id": .int,
      "atom_id": .int,
      "feed_id": .int,
      "read_count": .int
    ]
  }
  
  static var selectedFields: [String] {
    return [
      "id", "atom_id", "feed_id", "read_count"
    ]
  }
  
  static func get(by atomId: Int, feedId: Int) -> Self? {
    let condition = " where atom_id=\(atomId) and feed_id=\(feedId)"
    let model: Self? = Self.select(with: condition).first
    return model
  }
  
  @discardableResult
  func increment() -> Bool {
    let sql = "update \(Self.tableName) set read_count = \(self.readCount + 1) where id=\(self.id)"
    do {
      try Self.update(with: sql)
      return true
    } catch {
      print("rss feed read increment error: \(error)")
    }
    return false
  }
}
