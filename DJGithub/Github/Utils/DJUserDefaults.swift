//
//  DJUserDefaults.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/25.
//

import Foundation

struct DJUserDefaults {
  
  enum Keys: String {
    case searchHistoryWords
    case userInfo
    case staredRepos
  }
  
  static func allHistorySearchWords() -> [String] {
    return UserDefaults.standard.stringArray(forKey: Keys.searchHistoryWords.rawValue) ?? []
  }
  
  static func addHistoryWord(with word: String) {
    var words = allHistorySearchWords()
    guard !words.contains(word) else { return }
    if words.count >= 20 {
      words.removeLast()
    }
    words.insert(word, at: 0)
    UserDefaults.standard.setValue(words, forKey: Keys.searchHistoryWords.rawValue)
  }
  
  static func userInfo() -> UserViewer? {
    guard let userInfo = UserDefaults.standard.string(forKey: Keys.userInfo.rawValue) else { return nil }
    return try? DJDecoder(data: userInfo.data(using: .utf8)).decode()
  }
  
  static func save(with user: UserViewer?) {
    guard let dict = DJEncoder(model: user).encode(),
    let data = try? JSONSerialization.data(withJSONObject: dict),
    let userInfo = String(data: data, encoding: .utf8) else { return }
    UserDefaults.standard.set(userInfo, forKey: Keys.userInfo.rawValue)
  }
  
  static func getStaredRepos() -> [Repo]? {
    let str = UserDefaults.standard.string(forKey: Keys.staredRepos.rawValue)
    return try? DJDecoder(data: str?.data(using: .utf8)).decode()
  }
  
  static func saveStaredRepos(_ repos: [Repo]) {
    guard let dict = DJEncoder(model: repos).encode(),
    let data = try? JSONSerialization.data(withJSONObject: dict),
    let values = String(data: data, encoding: .utf8) else { return }
    UserDefaults.standard.set(values, forKey: Keys.userInfo.rawValue)
  }
  
}
