//
//  LanguageManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import UIKit
import CoreData

struct LanguageManager {

  static var mapping: [String: String] = [:]
  
  static func save(_ languages: [Language]) async {
    Task {
      for language in languages {
        if mapping[language.language] == nil {
          language.insert()
        }
      }
    }
  }
  
  static func loadLanguageMapping() async {
    var rs = [String: String]()
    for r in Language.selectAll() {
      if let language = r["language"] as? String, let hex = r["hex"] as? String {
        rs[language] = hex
      }
    }
    LanguageManager.mapping = rs
  }
  
}
