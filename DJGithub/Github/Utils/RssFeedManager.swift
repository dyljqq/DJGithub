//
//  RssFeedManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import Foundation

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
      for atom in atoms {
        if atom.title.contains("摸鱼") {
          await loadFeeds(by: atom)
        }
      }
//      await withThrowingTaskGroup(of: Void.self) { group in
//        for atom in atoms {
//          group.addTask {
//            await self.loadFeeds(by: atom)
//          }
//        }
//      }
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
  
  func loadFeeds(by atom: RssFeedAtom) async {
    print("----------------------------------")
    print("start fetch \(atom.title)'s feeds")
    let feeds = await FeedManager.fetchRssFeeds(with: atom.feedLink)
    for var feed in feeds {
      let selectedFeeds: [RssFeed] = RssFeed.select(with: " where title='\(feed.title)'")
      if selectedFeeds.isEmpty {
        feed.atomId = atom.id
        feed.insert()
      }
    }
    print("end fetch \(atom.title)'s feeds")
    print("----------------------------------")
  }
  
  static func getFeeds(by atomId: Int) async -> [RssFeed] {
    let d = RssFeed.selectAll()
    let feeds: [RssFeed] = RssFeed.select(with: " where atom_id=\(atomId)")
    return feeds
  }
}
