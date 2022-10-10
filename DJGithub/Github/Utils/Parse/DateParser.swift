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

/**
 yyyy-MM-dd'T'HH:mm:ssZ // 24小时制
 yyyy-MM-dd'T'hh:mm:ssZ // 12小时制
 */
let FeedDateParser = DateParser(with: "yyyy-MM-dd'T'HH:mm:ssZ")
