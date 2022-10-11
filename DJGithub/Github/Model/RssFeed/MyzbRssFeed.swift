//
//  MyzbRssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

// 摸鱼周报
struct MyzbRssFeedChannel: RssFeedParsable {
  struct MyzbRssFeedInfo: RssFeedParsable {
    var title: String
    var pubDate: String
    var item: [MyzbRssFeed]
  }
  
  var channel: MyzbRssFeedInfo
  
  func convert() -> [RssFeed] {
    return channel.item.compactMap { $0.convert() }
  }
}

struct MyzbRssFeed: RssFeedParsable {
  typealias DataType = RssFeed

  var title: String?
  var link: String?
  var content: String?
  var pubDate: String?
  
  enum CodingKeys: String, CodingKey {
    case title, link, content = "content:encoded", pubDate
  }
  
  func convert() -> RssFeed {
    let dateString: String?
    if let pubDate = self.pubDate, let date = DateHelper.standard.dateFromRFC822String(pubDate) {
      dateString = DateHelper.standard.dateToString(date)
    } else {
      dateString = pubDate
    }
    return RssFeed(title: title ?? "", updated: dateString ?? "", content: content ?? "", link: link ?? "")
  }
}
