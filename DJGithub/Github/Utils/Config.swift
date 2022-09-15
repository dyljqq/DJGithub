//
//  Config.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct Config {
  static let shared = Config()
  
  var authorization: String = ""
  
  init() {
    authorization = getAuthorization()
  }
  
  func getAuthorization() -> String {
    let d = DJFileManager.shared.getFile(with: "Config")
    return (d["Authorization"] as? String) ?? ""
  }
}
