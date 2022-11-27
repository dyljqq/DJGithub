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
    case viewerName
    case crash
    case feeds
    case feedInfo
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
    guard let user = user else { return }
    saveViewerName(user.login)

    guard let dict = DJEncoder(model: user).encode(),
          let data = try? JSONSerialization.data(withJSONObject: dict),
          let userInfo = String(data: data, encoding: .utf8) else { return }
    UserDefaults.standard.set(userInfo, forKey: Keys.userInfo.rawValue)
  }

  static func removeUserInfo() {
    UserDefaults.standard.removeObject(forKey: Keys.viewerName.rawValue)
    UserDefaults.standard.removeObject(forKey: Keys.userInfo.rawValue)
  }

  static func getStaredRepos() -> [Repo]? {
    let str = UserDefaults.standard.string(forKey: Keys.staredRepos.rawValue)
    return try? DJDecoder(data: str?.data(using: .utf8)).decode()
  }

  static func saveStaredRepos(_ repos: [Repo]) {
    guard let dict = DJEncoder(model: repos).encode(),
          let data = try? JSONSerialization.data(withJSONObject: dict),
          let values = String(data: data, encoding: .utf8) else {
      return
    }
    UserDefaults.standard.set(values, forKey: Keys.staredRepos.rawValue)
  }

  static func viewerName() -> String {
    return UserDefaults.standard.string(forKey: Keys.viewerName.rawValue) ?? ""
  }

  static func saveViewerName(_ name: String) {
    UserDefaults.standard.set(name, forKey: Keys.viewerName.rawValue)
  }

  static func clearViewerInfo() {
    UserDefaults.standard.removeObject(forKey: Keys.userInfo.rawValue)
    UserDefaults.standard.removeObject(forKey: Keys.viewerName.rawValue)
  }

  static func setCrashInfo(with info: [String: String]) {
    UserDefaults.standard.set(info, forKey: Keys.crash.rawValue)
  }

  static func getCrashInfo() -> [String: String] {
    return UserDefaults.standard.value(forKey: Keys.crash.rawValue) as? [String: String] ?? [:]
  }

  static func setFeeds(with feeds: Feeds?) {
    guard let feeds = feeds, let dict = DJEncoder(model: feeds).encode() as? [String: Any] else { return }
    UserDefaults.standard.set(dict, forKey: Keys.feeds.rawValue)
  }

  static func getFeeds() -> Feeds? {
    guard let dict = UserDefaults.standard.value(forKey: Keys.feeds.rawValue) as? [String: Any] else { return nil }
    return try? DJDecoder(dict: dict).decode()
  }

  static func setFeedInfo(with feedInfo: FeedInfo?) {
    set(with: feedInfo, key: Keys.feedInfo)
  }

  static func getFeedInfo() -> FeedInfo? {
    return get(with: Keys.feedInfo)
  }

  static func set<T: DJCodable>(with model: T?, key: Keys) {
    guard let dict = DJEncoder(model: model).encode() as? [String: Any] else { return }
    UserDefaults.standard.set(dict, forKey: key.rawValue)
  }

  static func get<T: DJCodable>(with key: Keys) -> T? {
    guard let dict = UserDefaults.standard.value(forKey: key.rawValue) as? [String: Any] else { return nil }
    return try? DJDecoder(dict: dict).decode()
  }

}
