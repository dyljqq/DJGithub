//
//  LocalRssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

struct RssFeedAtom: DJCodable {
  var id: Int
  var title: String
  var des: String
  var siteLink: String
  var feedLink: String
}
