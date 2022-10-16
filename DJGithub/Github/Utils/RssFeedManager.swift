//
//  RssFeedManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation
import Combine

class RssFeedManager: NSObject {
  static let RssFeedAtomUpdateNotificationKey = NSNotification.Name("RssFeedAtomUpdateNotification")
  
  override init() {
    super.init()
    
    try? RssFeedAtom.createTable()
    try? RssFeed.createTable()
    Task {
      let atoms = await loadAtoms()
      await withThrowingTaskGroup(of: Void.self) { group in
        for atom in atoms {
          group.addTask {
            await self.loadFeeds(by: atom)
          }
        }
      }
    }
  }
  
  func loadAtoms() async -> [RssFeedAtom] {
    let atoms: [RssFeedAtom] = RssFeedAtom.select(with: " order by update_time desc")
    if atoms.isEmpty {
      await self.saveAtoms()
    }
    return RssFeedAtom.select(with: " order by update_time desc")
  }
  
  func saveAtoms() async {
    let atoms: [RssFeedAtom] = loadBundleJSONFile("rssfeed")
    for atom in atoms {
      let storedAtoms = RssFeedAtom.select(with: " where feed_link='\(atom.feedLink)'") as [RssFeedAtom]
      if storedAtoms.isEmpty {
        try? atom.insert()
      }
    }
  }
  
  static func updateAtom(with title: String, description: String, feedLink: String) {
    let sql = "update \(RssFeedAtom.tableName) set title='\(title)', des='\(description)' where feed_link='\(feedLink)'"
    try? RssFeedAtom.update(with: sql)
    
    NotificationCenter.default.post(name: RssFeedAtomUpdateNotificationKey, object: ["feedLink": feedLink])
  }
  
  func loadFeeds(by atom: RssFeedAtom) async {
    print("----------------------------------")
    print("start fetch \(atom.title)'s feeds")
    guard let info = await FeedManager.fetchRssInfo(with: atom.feedLink) as RssFeedInfo? else {
      print("failed to load feeds: \(atom.title)")
      return
    }
    print("[\(atom.title)] fetches \(info.entries.count)'s items.")
    for var feed in info.entries {
      let selectedFeeds: [RssFeed] = RssFeed.select(with: " where title=\"\(feed.title)\" order by updated desc")
      if selectedFeeds.isEmpty {
        feed.atomId = atom.id
        feed.unread = true
        try? feed.insert()
      } else {
        feed.update(with: feed)
      }
    }
    print("end fetch \(atom.title)'s feeds")
    print("----------------------------------")
  }
  
  static func getFeeds(by atomId: Int) async -> [RssFeed] {
    let feeds: [RssFeed] = RssFeed.select(with: " where atom_id=\(atomId)")
    return feeds
  }
  
  func addAtom(with atomUrl: String, desc: String) async -> Bool {
    guard !RssFeedAtom.isExistedByFeedLink(atomUrl) else { return false }
    if let info = await FeedManager.fetchRssInfo(with: atomUrl) as RssFeedInfo? {
      let atom =  RssFeedAtom.convert(with: info, feedLink: atomUrl, desc: desc)
      do {
        try atom.insert()
        await loadFeeds(by: atom)
        return true
      } catch {
        print("Failed to load atom: \(error)")
      }
    }
    return false
  }
}

fileprivate extension RssFeedAtom {
  static func convert(with rssFeedInfo: RssFeedInfo, feedLink: String, desc: String) -> RssFeedAtom {
    let atom = RssFeedAtom(
      title: rssFeedInfo.title, desc: desc, feedLink: feedLink
    )
    return atom
  }
}
