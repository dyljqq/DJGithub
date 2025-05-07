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
    
    static func asyncFetchFeedInfo() async -> FeedInfo? {
        if let feeds = await asyncFetchFeeds(),
           let feedInfo = await FeedManager.fetchFeedInfo(with: "\(feeds.currentUserUrl)&page=1") {
            DJUserDefaults.setFeedInfo(with: feedInfo)
            return feedInfo
        }
        return nil
    }
    
    private static func asyncFetchFeeds() async -> Feeds? {
        if let feeds = await FeedManager.getFeeds() {
            Self.updateLocalFeeds(feeds)
            return feeds
        } else {
            return nil
        }
    }
    
    private static func updateLocalFeeds(_ feeds: Feeds?) {
        DJUserDefaults.setFeeds(with: feeds)
    }
    
    private func fetchLocalFeeds() -> Feeds? {
        return DJUserDefaults.getFeeds()
    }
}
