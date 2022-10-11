//
//  RssFeedManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation
import Combine

class RssFeedManager: NSObject {
  override init() {
    super.init()
    RssFeedAtom.createTable()
    RssFeed.createTable()
    Task {
      await self.saveAtoms()
    }

    Task {
      let atoms = await loadAtoms()      
      await withThrowingTaskGroup(of: Void.self) { group in
        for atom in atoms {
          switch atom.atomType {
          case .swiftOrg: group.addTask { let _ = await self.loadFeeds(by: atom) as SwiftOrgRssFeedInfo? }
          case .myzb: group.addTask { let _ = await self.loadFeeds(by: atom) as MyzbRssFeedChannel? }
          default: break
          }
        }
      }
    }
  }
  
  func loadAtoms() async -> [RssFeedAtom] {
    let atoms: [RssFeedAtom] = RssFeedAtom.selectAll()
    if atoms.isEmpty {
      await self.saveAtoms()
    }
    return RssFeedAtom.selectAll()
  }
  
  func saveAtoms() async {
    let atoms: [RssFeedAtom] = loadBundleJSONFile("rssfeed")
    for atom in atoms {
      let storedAtoms = RssFeedAtom.select(with: " where id=\(atom.id)") as [RssFeedAtom]
      if storedAtoms.isEmpty {
        atom.insert()
      }
    }
  }
  
  @discardableResult
  func loadFeeds<T: RssFeedParsable>(by atom: RssFeedAtom) async -> T? {
    print("----------------------------------")
    print("start fetch \(atom.title)'s feeds")
    guard let info = await FeedManager.fetchRssInfo(with: atom.feedLink) as T? else {
      print("failed to load feeds: \(atom.title)")
      return nil
    }
    let feeds = info.convert()
    print("fetched feeds: \(atom.title) feeds count: \(feeds.count)")
    for var feed in feeds {
      let selectedFeeds: [RssFeed] = RssFeed.select(with: " where title=\"\(feed.title)\"")
      if selectedFeeds.isEmpty {
        feed.atomId = atom.id
        feed.insert()
      }
    }
    print("end fetch \(atom.title)'s feeds")
    print("----------------------------------")
    return info
  }
  
  static func getFeeds(by atomId: Int) async -> [RssFeed] {
    let feeds: [RssFeed] = RssFeed.select(with: " where atom_id=\(atomId)")
    return feeds
  }
}
