//
//  SQLTable.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import Foundation

enum FieldType {
  case int
  case text
  case bigint
  case unknown
  
  var name: String? {
    switch self {
    case .int: return "INTEGER"
    case .text: return "TEXT"
    case .bigint: return "BIGINT"
    case .unknown: return nil
    }
  }
}

protocol SQLTable {
  static var tableName: String { get }
  static var fields: [String] { get }
  static var uniqueKeys: [String] { get }
  static var fieldsTypeMapping: [String: FieldType] { get }
  static var needFieldId: Bool { get }
  static var selectedFields: [String] { get }
  var fieldsValueMapping: [String: Any] { get }
}

let serialQueue = DispatchQueue(label: "com.dyljqq.dbmanager")

extension SQLTable {
  
  static var needFieldId: Bool {
    return true
  }
  
  static var selectedFields: [String] {
    var fs: [String] = []
    if needFieldId {
      fs.append("id")
    }
    fs.append(contentsOf: fields)
    return fs
  }
  
  static var uniqueKeys: [String] {
    return []
  }
  
  static var tableSql: String {
    var rs: [String] = needFieldId ? ["id INTEGER PRIMARY KEY AUTOINCREMENT not null"] : []
    
    for field in Self.fields {
      guard let typ = Self.fieldsTypeMapping[field], let name = typ.name else {
        continue
      }
      rs.append("\(field) \(name)")
    }
    
    for uk in uniqueKeys {
      rs.append("UNIQUE(\(uk))")
    }
    
    return "CREATE TABLE IF NOT EXISTS \(Self.tableName)(\(rs.joined(separator: ",")))"
  }
  
  var fieldsValueMapping: [String: Any] {
    return [:]
  }
  
  static var insertSql: String {
    return "insert into \(tableName)(\(fields.joined(separator: ","))) values(\(fields.compactMap { _ in  "?" }.joined(separator: ",")));"
  }
  
  static func select<T: DJCodable>(with condition: String? = nil) -> [T] {
    serialQueue.sync {
      var sql = "select \(Self.selectedFields.joined(separator: ",")) from \(Self.tableName)"
      if let condition = condition {
        sql += condition
      }

      if let rs = try? query(with: sql) {
        return rs.compactMap { try? DJDecoder(dict: $0).decode() }
      }
      return []
    }
  }
  
  static func selectAll<T: DJCodable>() -> [T] {
    return Self.select()
  }
  
  static func addNewFields(with dict: [String: Any]) {
    for key in dict.keys {
      do {
        try addNewField(with: key)
      } catch {
        print("addNewFields: \(error)")
      }
    }
    updateNewFields(with: dict)
  }
  
  static func updateNewFields(with dict: [String: Any]) {
    let s = dict.map { "\($0)=\($1)" }.joined(separator: ", ")
    let sql = "update \(Self.tableName) set \(s);"
    try? update(with: sql)
  }
}
