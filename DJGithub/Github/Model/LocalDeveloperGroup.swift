//
//  LocalDeveloperGroup.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import Foundation

struct LocalDeveloperGroup: DJCodable {
  var name: String
  var id: Int
  var users: [LocalDeveloper] = []
}

struct LocalDeveloper: DJCodable {
  var id: Int
  var name: String
  var des: String?
  var avatarUrl: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case des
    case avatarUrl
  }
  
  mutating func update(avatarUrl: String) {
    self.avatarUrl = avatarUrl
  }
}

extension LocalDeveloper: SQLTable {
  static var tableName: String {
    return "LocalDeveloper"
  }
  
  static var fields: [String] {
    return ["name", "des", "avatarUrl"]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "name": .text,
      "des": .text,
      "avatarUrl": .text
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "name": self.name,
      "des": self.des ?? "",
      "avatarUrl": self.avatarUrl ?? ""
    ]
  }
  
  static func get(by name: String) -> Self? {
    let sql = "select * from \(tableName) where name='\(name)'"
    guard let rs = store.execute(.select, sql: sql, type: LocalDeveloper.self) as? [[String: Any]],
          !rs.isEmpty else { return nil }
    return DJDecoder(dict: rs[0]).decode()
  }
  
  static func update(with id: String, des: String, avatarUrl: String) -> Self? {
    let sql = "update \(tableName) set des=\(des), avatarUrl=\(avatarUrl) where name=\(id)"
    store.execute(.update, sql: sql, type: LocalDeveloper.self)
    return get(by: id)
  }
}
