//
//  ConfigManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import Foundation

let store = loadDatabase()

func loadDatabase() -> SQLiteDatabase? {
  let db: SQLiteDatabase?
  do {
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("github.sqlite")
    db = try SQLiteDatabase.open(path: fileURL.path)
    print("Successfully opened connection to database.")
  } catch {
    print("Unable to open database.")
    db = nil
  }
  
  return db
}

class ConfigManager: NSObject {
  static let shared = ConfigManager()
  static var config: Config = Config()
  let rssFeedManager: RssFeedManager = RssFeedManager()
  let languageManager = LanguageManager()
  
  static var viewer: UserViewer? {
    return LocalUserManager.getUser()
  }

  var viewerName: String {
    return ConfigManager.viewer?.login ?? ""
  }
  static var isLoadedViewer: Bool {
    return !LocalUserManager.getViewerName().isEmpty
  }
  
  override init() {
    super.init()
  }
  
  func load() {
    loadConfig()
  }
  
  func loadConfig(completionHandler: ((Config) -> ())? = nil) {
    ConfigManager.config = loadBundleJSONFile("config")
  }
  
  static func checkOwner(by userName: String) -> Bool {
    if let viewer = viewer {
      return viewer.login == userName
    } else {
      if let viewer = LocalUserManager.getUser() {
        return viewer.login == userName
      }
    }
    return userName == config.userName
  }
  
}
