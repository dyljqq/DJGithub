//
//  ConfigManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import Foundation

struct ConfigManager {
  static let shared = ConfigManager()
  static var config: Config = Config()
  
  static func loadConfig(completionHandler: ((Config) -> ())? = nil) {
    ConfigManager.config = loadBundleJSONFile("config")
  }
  
  static func checkOwner(by userName: String) -> Bool {
    return userName == config.userName
  }
}
