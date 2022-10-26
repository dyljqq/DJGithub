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
  
  init() {
    try? Language.createTable()
  }
  
  static func save(_ languages: [Language]) async {
    Task {
      for language in languages {
        if Language.get(with: language.language) == nil {
          try? language.insert()
        }
      }
      await loadLanguageMapping()
    }
  }
  
  static func loadLanguageMapping() async {
    var rs = [String: String]()
    let languages: [Language] = Language.selectAll()
    for language in languages {
      rs[language.language] = language.hex
    }
    LanguageManager.mapping = rs
  }
  
  static func save(with languageName: String, color: String) async {
    var col = color
    if color.hasPrefix("#") {
      col = String(color.dropFirst())
    }
    if let lang = Language.get(with: languageName) {
      if col != lang.hex {
        lang.update(with: languageName, color: col)
      }
    } else {
      try? Language(language: languageName, hex: col).insert()
    }
    mapping[languageName] = color
  }
  
}
