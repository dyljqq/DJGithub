//
//  SearchWordManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/2.
//

import Foundation

private let SearchWordKey = "SearchWordKey"

struct SearchWordManager {
  static let shared = SearchWordManager()

  func save(with word: String) {
    DJUserDefaults.addHistoryWord(with: word)
  }

  func load() -> [String] {
    return DJUserDefaults.allHistorySearchWords()
  }

  func move(index: Int, to top: Int) {
    var words = self.load()
    guard words.count > index else { return }
    let word = words[index]
    words.remove(at: index)
    words.insert(word, at: 0)
    UserDefaults.standard.setValue(words, forKey: SearchWordKey)
  }

  func removeAll() {
    UserDefaults.standard.set(nil, forKey: SearchWordKey)
  }

}
