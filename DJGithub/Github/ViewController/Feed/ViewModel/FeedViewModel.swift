//
//  FeedViewModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/27.
//

import Foundation

struct FeedViewModel {
  var feedInfoObserver: DJObserverable<FeedInfo> = DJObserverable()

  var feeds: Feeds? {
    return DJUserDefaults.getFeeds()
  }

  func fetchLocalFeedInfo() -> FeedInfo? {
    return DJUserDefaults.getFeedInfo()
  }

  func asyncFetchFeedInfo() async -> FeedInfo? {
    if let feeds = await asyncFetchFeeds(),
     let feedInfo = await FeedManager.fetchFeedInfo(with: "\(feeds.currentUserUrl)&page=1") {
      DJUserDefaults.setFeedInfo(with: feedInfo)
      return feedInfo
    }
    return nil
  }

  private func fetchFeedInfo(with completionHandler: @escaping (FeedInfo) -> Void) {
    Task {
      if let feeds = await asyncFetchFeeds(),
       let feedInfo = await FeedManager.fetchFeedInfo(with: "\(feeds.currentUserUrl)&page=1") {
        DJUserDefaults.setFeedInfo(with: feedInfo)
        completionHandler(feedInfo)
      }
    }
  }

  private func asyncFetchFeeds() async -> Feeds? {
    try? await withCheckedThrowingContinuation { continuation in
      self.fetchFeeds { feeds in
        continuation.resume(returning: feeds)
      }
    }
  }

  private func fetchFeeds(_ completionHandler: @escaping (Feeds?) -> Void) {
    Task {
      if let feeds = await FeedManager.getFeeds() {
        updateLocalFeeds(feeds)
        completionHandler(feeds)
      } else {
        completionHandler(nil)
      }
    }
  }

  private func updateLocalFeeds(_ feeds: Feeds?) {
    DJUserDefaults.setFeeds(with: feeds)
  }

  private func fetchLocalFeeds() -> Feeds? {
    return DJUserDefaults.getFeeds()
  }
}
