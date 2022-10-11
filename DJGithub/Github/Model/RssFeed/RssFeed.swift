//
//  RssFeed.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

protocol RssFeedCinvertable {
  func conver() -> RssFeed
}

struct RssFeed: DJCodable {
  let title: String
  let updated: String
  let content: String
  let link: String
}
