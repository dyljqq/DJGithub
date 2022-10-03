//
//  LocalDeveloperGroup.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import Foundation

struct LocalDeveloperGroup: DJCodable {
  var id: Int
  var name: String
  var users: [LocalDeveloper]?

  var developers: [LocalDeveloper] {
    return self.users ?? []
  }
  
  enum CodingKeys: String, CodingKey {
    case id, name, users
  }
}

extension LocalDeveloperGroup: SQLTable {
  static var needFieldId: Bool {
    return false
  }
  
  static var tableName: String {
    return "LocalDeveloperGroup"
  }
  
  static var fields: [String] {
    return [
      "id", "name"
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "id": self.id,
      "name": self.name,
    ]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "id": .bigint,
      "name": .text
    ]
  }

  static func get(by id: Int) -> Self? {
    let sql = "select \(Self.selectedFields.joined(separator: ",")) from \(tableName) where id=\(id)"
    guard let rs = store.execute(.select, sql: sql, type: LocalDeveloperGroup.self) as? [[String: Any]],
          !rs.isEmpty else { return nil }
    return DJDecoder(dict: rs[0]).decode()
  }
  
  static func update(by groupId: Int, name: String) {
    let sql = "update \(tableName) set name='\(name)' where id=\(groupId)"
    store.execute(.update, sql: sql, type: LocalDeveloperGroup.self)
  }
  
}

struct LocalDeveloper: DJCodable {
  var name: String
  var des: String?
  var avatarUrl: String?
  var groupId: Int?
  
  enum CodingKeys: String, CodingKey {
    case name
    case des
    case avatarUrl
    case groupId
  }
  
  mutating func update(avatarUrl: String) {
    self.avatarUrl = avatarUrl
  }
}

extension LocalDeveloper: SQLTable {
  static var needFieldId: Bool {
    return false
  }
  
  static var tableName: String {
    return "LocalDeveloper"
  }
  
  static var fields: [String] {
    return ["name", "des", "avatarUrl", "groupId"]
  }
  
  static var fieldsTypeMapping: [String : FieldType] {
    return [
      "name": .text,
      "des": .text,
      "avatarUrl": .text,
      "groupId": .bigint
    ]
  }
  
  var fieldsValueMapping: [String : Any] {
    return [
      "name": self.name,
      "des": self.des ?? "",
      "avatarUrl": self.avatarUrl ?? "",
      "groupId": self.groupId ?? 0
    ]
  }
  
  static func get(by name: String) -> Self? {
    let sql = "select \(Self.selectedFields.joined(separator: ",")) from \(tableName) where name='\(name)'"
    guard let rs = store.execute(.select, sql: sql, type: LocalDeveloper.self) as? [[String: Any]],
          !rs.isEmpty else { return nil }
    return DJDecoder(dict: rs[0]).decode()
  }
  
  static func get(by groupId: Int) -> [Self?] {
    let sql = "select \(Self.selectedFields.joined(separator: ",")) from \(tableName) where groupId=\(groupId)"
    guard let rs = store.execute(.select, sql: sql, type: LocalDeveloper.self) as? [[String: Any]],
          !rs.isEmpty else { return [] }
    let developers: [Self?]? = DJDecoder(value: rs).decode()
    return developers ?? []
  }
  
  static func update(with id: String, des: String, avatarUrl: String, groupId: Int) -> Self? {
    let sql = "update \(tableName) set des='\(des)', avatarUrl='\(avatarUrl)', groupId=\(groupId) where name='\(id)'"
    store.execute(.update, sql: sql, type: LocalDeveloper.self)
    return get(by: id)
  }
}
