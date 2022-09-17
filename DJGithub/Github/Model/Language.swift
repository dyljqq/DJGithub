//
//  Language.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import Foundation

struct Language: Decodable {
  var id: Int
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
    let sql = "select * from \(tableName) where language = \(language)"
    guard let rs = store.execute(.select, sql: sql, type: Language.self) as? [[String: Any]], !rs.isEmpty else {
      return nil
    }
    return DJDecoder<Self>(dict: rs[0]).decode()
  }
}
