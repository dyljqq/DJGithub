//
//  Language.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import Foundation

struct Language: DJCodable {
  var id: Int?
  var language: String
  var hex: String
}

extension Language: SQLTable {
  static var tableName: String {
    return "language"
  }
  
  static var fields: [String] {
    return [
      "language",
      "hex"
    ]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "language": .text,
      "hex": .text
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "language": self.language,
      "hex": self.hex
    ]
  }
  
  static var uniqueKeys: [String] {
    return ["id"]
  }
  
  static func get(with language: String) -> Self? {
    return Self.select(with: " where language=\"\(language)\"").first
  }
  
  func update(with languageName: String, color: String) {
    let sql = "update \(Self.tableName) set hex=\"\(color)\" where language=\"\(languageName)\""
    try? Self.update(with: sql)
  }
}
