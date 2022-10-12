//
//  LocalRssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

enum RssFeedAtomType: String, DJCodable {
  case myzb, swiftOrg, tsai, ssp, onevcat
  case swiftLee, swiftWithMajid, zhouzi, daiming
  case sundell, fiveStars, coalescing, swiftUIWeekly
  case swiftlyRushWeekly, iOSDevWeekly, ruanyifeng
  case theSwiftDev, afer, jihe
}

struct RssFeedAtom: DJCodable {
  var id: Int
  var title: String
  var des: String
  var siteLink: String
  var feedLink: String
  
  var atomType: RssFeedAtomType
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
      "id", "title", "des", "site_link", "feed_link", "atom_type"
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
      "id", "title", "des", "site_link", "feed_link", "atom_type"
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "title": self.title,
      "id": self.id,
      "des": self.des,
      "site_link": self.siteLink,
      "feed_link": self.feedLink,
      "atom_type": self.atomType.rawValue
    ]
  }
  
}

extension RssFeedAtom {
  var hasFeeds: Bool {
    let feeds: [RssFeed] = RssFeed.select(with: " where atom_id=\(self.id)")
    return !feeds.isEmpty
  }
}
