//
//  ConfigManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import Foundation

class ConfigManager: NSObject {
  static let shared = ConfigManager()
  static var config: Config = Config()
  let rssFeedManager: RssFeedManager = RssFeedManager()
  
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
    return userName == config.userName
  }
  
}
