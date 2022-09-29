//
//  ConfigManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import Foundation

struct ConfigManager {
  static let shared = ConfigManager()
  
  static var config: Config?
  
  static func loadConfig() {
    DispatchQueue.global().async {
      let config: Config = loadBundleJSONFile("config.json")
      DispatchQueue.main.async {
        ConfigManager.config = config
      }
    }
  }
}
