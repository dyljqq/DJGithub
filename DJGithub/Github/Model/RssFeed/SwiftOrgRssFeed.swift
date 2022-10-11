//
//  SwiftOrgRssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

struct SwiftOrgRssFeedInfo: RssFeedParsable {
  var title: String
  var updated: String
  var entry: [SwiftOrgRssFeed]
  
  func convert() -> [RssFeed] {
    return self.entry.compactMap { $0.convert() }
  }
}

struct SwiftOrgRssFeed: RssFeedParsable {
  var title: String
  var link: SwiftOrgRssFeedLink
  var content: String?
  var updated: String
  
  func convert() -> RssFeed {
    let dateString: String
    if let date = DateHelper.standard.dateFromRFC822String(updated) {
      dateString = DateHelper.standard.dateToString(date)
    } else {
      dateString = updated
    }
    return RssFeed(title: title, updated: dateString, content: content ?? "", link: link.href ?? "")
  }
}

struct SwiftOrgRssFeedLink: DJCodable {
  var href: String?
}
