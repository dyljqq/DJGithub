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
  
  func execute()
      
  static func decode<T: DJCodable>(_ hash: [String: Any]) -> T?
    
}

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
    
  func execute() {
      // TODO
  }
  
  static func decode<T: DJCodable>(_ hash: [String: Any]) -> T? {
      return try? DJDecoder<T>(dict: hash).decode()
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
  
  static func createTable() {
      store.createTable(tableSql)
  }
  
  @discardableResult
  func execute(_ operation: SqlOperation, sql: String) -> Any? {
      switch operation {
      case .insert: return store.execute(operation, sql: sql, model: self)
      case .select: return store.execute(operation, sql: sql, model: self, type: Self.self)
      default: break
      }
      return nil
  }
  
  func insert() {
    execute(.insert, sql: Self.insertSql)
  }
  
  func select() -> [[String: Any]] {
    let sql = "select \(Self.selectedFields.joined(separator: ",")) from \(Self.tableName)"
      guard let rs = execute(.select, sql: sql) as? [[String: Any]] else {
          return []
      }
      return rs
  }
  
  static func selectAll() -> [[String: Any]] {
    let sql = "select \(Self.selectedFields.joined(separator: ",")) from \(Self.tableName)"
      let rs = store.execute(.select, sql: sql, type: Self.self) as? [[String: Any]] ?? []
      return rs
  }
  
  static func deleteTable() {
      let sql = "drop table \(tableName)"
      store.execute(.delete, sql: sql, type: Self.self)
  }
  
  static func select<T: DJCodable>(with condition: String? = nil) -> [T] {
    var sql = "select \(Self.selectedFields.joined(separator: ",")) from \(Self.tableName)"
    if let condition = condition {
      sql += condition
    }
    if let rs = store.execute(.select, sql: sql, type: Self.self)  as? [[String: Any]] {
      return rs.compactMap { try? DJDecoder(dict: $0).decode() }
    }
    return []
  }
    
  
  static func selectAll<T: DJCodable>() -> [T] {
    return Self.select()
  }
}
