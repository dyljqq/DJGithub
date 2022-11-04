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
  static let RssFeedAtomReadFeedNotificationKey = NSNotification.Name("RssFeedAtomReadFeedNotification")
  
  static let shared = RssFeedManager()
  
  var atoms: [RssFeedAtom] = []
  var readMapping: [String: Int] = [:]
  var loadedFeedsFinishedClosure: (() -> ())?
  
  override init() {
    super.init()
    
    try? RssFeedAtom.createTable()
    try? RssFeed.createTable()
    try? RssFeedRead.createTable()
    
    loadReadStatus()
    
    Task {
      self.atoms = await loadAtoms()
      await withThrowingTaskGroup(of: Void.self) { group in
        for atom in atoms {
          group.addTask {
            await self.loadFeeds(by: atom)
          }
        }
        loadedFeedsFinishedClosure?()
      }
    }
  }
  
  func loadAtoms() async -> [RssFeedAtom] {
    guard self.atoms.isEmpty else {
      return atoms
    }
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
    let lastFeeds: [RssFeed]? = RssFeed.select(with: " where atom_id=\(atom.id) order by updated desc")
    for var feed in info.entries {
      if let lastFeed = lastFeeds?.first, lastFeed.updated >= feed.updated {
        break
      }
      feed.feedLink = atom.feedLink
      feed.atomId = atom.id
      try? feed.insert()
    }
    print("end fetch \(atom.title)'s feeds")
    print("----------------------------------")
  }
  
  static func getFeeds(by atom_id: Int) async -> [RssFeed] {
    return RssFeed.select(with: " where atom_id=\(atom_id)")
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
  
  func loadReadStatus() {
    let models: [RssFeedRead] = RssFeedRead.selectAll()
    for model in models {
      readMapping[Self.readId(with: model.atomId, feedId: model.feedId)] = model.readCount
    }
  }
  
  static func readId(with atomId: Int, feedId: Int) -> String {
    return "\(atomId)_\(feedId)"
  }
  
  func readFeedCount(with atomId: Int) -> Int {
    guard let model = SqlCountModel.query(with: RssFeedRead.tableName, condition: " where atom_id=\(atomId)") else { return 0 }
    return model.count
  }
  
  func totalFeedsCount(with atomId: Int) -> Int {
    guard let model = SqlCountModel.query(with: RssFeed.tableName, condition: "where atom_id=\(atomId)") else { return 0 }
    return model.count
  }
  
  func totalFeedsReadStr(with atomId: Int) -> String {
    return "\(readFeedCount(with: atomId))/\(totalFeedsCount(with: atomId))"
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
