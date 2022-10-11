//
//  FeedManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import Foundation

struct FeedManager {
  static func getFeeds() async -> Feeds? {
    return try? await APIClient.shared.model(with: GithubRouter.feeds)
  }
  
  static func fetchFeedInfo(with urlString: String) async -> FeedInfo? {
    return try? await APIClient.shared.data(with: urlString, decoder: DJXMLParser<FeedInfo>())
  }
  
  static func fetchRssInfo<T: DJCodable>(with urlString: String) async -> T? {
    return try? await APIClient.shared.data(with: urlString, decoder: DJXMLParser<T>()) as T?
  }
}
