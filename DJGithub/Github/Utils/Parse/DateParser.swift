//
//  DateParse.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import Foundation

struct DateParser {
  let dateFormatter = DateFormatter()
  
  init(with dateFormat: String) {
    dateFormatter.dateFormat = dateFormat
  }
  
  func string(from date: Date) -> String? {
    return dateFormatter.string(from: date)
  }
  
  func date(from string: String) -> Date? {
    return dateFormatter.date(from: string)
  }
  
}

extension Date {
  var dateFormatString: String {
    let diff = (Date.now.timeIntervalSince1970 - self.timeIntervalSince1970)
    if diff < 60 {
      return "\(diff) seconds ago"
    } else if diff >= 60 && diff < 3600 {
      return "\(Int(diff / 60)) minuts ago"
    } else if diff >= 3600 && diff < 24 * 3600 {
      return "\(Int(diff / 3600)) hours ago"
    } else if diff >= 24 * 3600 && diff <= 24 * 30 * 3600 {
      return "\(Int(diff / (24 * 3600))) days ago"
    } else if diff >= (24 * 30 * 3600) && diff < (12 * 30 * 24 * 30 * 3600) {
      return "\(Int(diff / (30 * 24 * 3600))) months ago"
    }
    return normalDateParser.string(from: self) ?? ""
  }
}

/**
 yyyy-MM-dd'T'HH:mm:ssZ // 24小时制
 yyyy-MM-dd'T'hh:mm:ssZ // 12小时制
 */
let FeedDateParser = DateParser(with: "yyyy-MM-dd'T'HH:mm:ssZ")
let normalDateParser = DateParser(with: "yyyy-MM-dd'T'HH:mm:ssZ")
