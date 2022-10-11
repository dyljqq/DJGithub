//
//  MyzbRssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

// 摸鱼周报
struct MyzbRssFeedChannel: DJCodable {
  struct MyzbRssFeedInfo: DJCodable {
    var title: String
    var pubDate: String
    var item: [MyzbRssFeed]
  }
  
  var channel: MyzbRssFeedInfo
}

struct MyzbRssFeed: DJCodable {
  var title: String?
  var link: String?
  var content: String?
  var pubDate: String?
  
  enum CodingKeys: String, CodingKey {
    case title, link, content = "content:encoded", pubDate
  }
}

extension MyzbRssFeed: RssFeedCinvertable {
  func conver() -> RssFeed {
    let dateString: String?
    if let pubDate = self.pubDate, let date = DateHelper.standard.dateFromRFC822String(pubDate) {
      dateString = DateHelper.standard.dateToString(date)
    } else {
      dateString = pubDate
    }
    return RssFeed(title: title ?? "", updated: dateString ?? "", content: content ?? "", link: link ?? "")
  }
}
