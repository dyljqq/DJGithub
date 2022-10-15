//
//  DBManage.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import Foundation
import SQLite3

enum SqlOperation {
  case insert
  case select
  case update
  case delete
  case createTable
}

enum SQLiteError: Error {
  case OpenDatabase(message: String)
  case Prepare(message: String)
  case Step(message: String)
  case Bind(message: String)
}

class SQLiteDatabase {
  
  var errorMessage: String {
    if let errorPointer = sqlite3_errmsg(db) {
      let errorMessage = String(cString: errorPointer)
      return errorMessage
    } else {
      return "No error message provided from sqlite."
    }
  }
  
  private let db: OpaquePointer?
  
  init(with db: OpaquePointer?) {
    self.db = db
  }
  
  static func open(path: String) throws -> SQLiteDatabase {
    var db: OpaquePointer?
    
    if sqlite3_open(path, &db) == SQLITE_OK {
      return SQLiteDatabase(with: db)
    } else {
      defer {
        if db != nil {
          sqlite3_close(db)
        }
      }
      
      if let errorPointer = sqlite3_errmsg(db) {
        let message = String(cString: errorPointer)
        throw SQLiteError.OpenDatabase(message: message)
      } else {
        throw SQLiteError
          .OpenDatabase(message: "No error message provided from sqlite.")
      }
    }
  }
  
  func closeDatabase(_ db: OpaquePointer?) {
    sqlite3_close(db)
  }
  
  deinit {
    self.closeDatabase(self.db)
  }
}

extension SQLiteDatabase {
  func prepareStatement(sql: String) throws -> OpaquePointer? {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
      throw SQLiteError.Prepare(message: errorMessage)
    }
    return statement
  }
}

extension SQLTable {
  
  static func createTable() throws {
    try serialQueue.sync {
      guard let createTableStatement = try? store?.prepareStatement(sql: tableSql) else {
        throw SQLiteError.Prepare(message: errorMessage)
      }
      defer {
        sqlite3_finalize(createTableStatement)
      }
      if sqlite3_step(createTableStatement) != SQLITE_DONE {
        throw SQLiteError.Step(message: errorMessage)
      }
    }
  }
  
  static func addNewField(with fieldName: String, comment: String = "") throws {
    try serialQueue.sync {
      guard let fieldType = fieldsTypeMapping[fieldName], let fieldTypeName = fieldType.name else { return }
      let fieldSql = "\(fieldName) \(fieldTypeName)"
      let sql = "ALTER TABLE \(tableName) ADD COLUMN \(fieldSql);"
      guard let createStatement = try? store?.prepareStatement(sql: sql) else {
        throw SQLiteError.Prepare(message: errorMessage)
      }
      defer {
        sqlite3_finalize(createStatement)
      }
      if sqlite3_step(createStatement) != SQLITE_DONE {
        throw SQLiteError.Step(message: errorMessage)
      }
    }
  }
  
  func insert() throws {
    try serialQueue.sync {
      let insertStatement = try store?.prepareStatement(sql: Self.insertSql)
      defer {
        sqlite3_finalize(insertStatement)
      }
      
      for (index, field) in Self.fields.enumerated() {
        if let fieldType = Self.fieldsTypeMapping[field] {
          let offset = Int32(index) + 1
          
          switch fieldType {
          case .int:
            if let value = self.fieldsValueMapping[field] as? Int {
              sqlite3_bind_int(insertStatement, offset, Int32(value))
            }
          case .text:
            let text: String = self.fieldsValueMapping[field] as? String ?? ""
            sqlite3_bind_text(insertStatement, offset, (text as NSString).utf8String, -1, nil)
          case .bigint:
            if let value = self.fieldsValueMapping[field] as? Int {
              sqlite3_bind_int64(insertStatement, offset, Int64(value))
            }
          default:
            throw SQLiteError.Bind(message: "Field value mapping error.")
          }
        }
      }
      
      if sqlite3_step(insertStatement) != SQLITE_DONE {
        throw SQLiteError.Bind(message: Self.errorMessage)
      }
    }
  }
  
  static func query(with querySql: String) throws -> [[String: Any]]? {
    guard let queryStatement = try? store?.prepareStatement(sql: querySql) else {
      return nil
    }
    defer {
      sqlite3_finalize(queryStatement)
    }
    var rs: [[String: Any]] = []
    while sqlite3_step(queryStatement) == SQLITE_ROW {
      var hash: [String: Any] = [:]
      for (index, field) in selectedFields.enumerated() {
        let offset = Int32(index)
        if let typ = fieldsTypeMapping[field] {
          switch typ {
          case .int:
            hash[field] = sqlite3_column_int(queryStatement, offset)
          case .text:
            if let v = sqlite3_column_text(queryStatement, offset) {
              hash[field] = String(cString: v)
            }
          case .bigint:
            hash[field] = sqlite3_column_int64(queryStatement, offset)
          default: break
          }
        }
      }
      rs.append(hash)
    }
    return rs
  }
  
  static func dropTable() throws {
    let sql = "drop table \(tableName)"
    try delete(with: sql)
  }
  
  static func delete(with sql: String) throws {
    try serialQueue.sync {
      guard let dropStatement = try? store?.prepareStatement(sql: sql) else {
        throw SQLiteError.Prepare(message: errorMessage)
      }
      defer {
        sqlite3_finalize(dropStatement)
      }
      if sqlite3_step(dropStatement) != SQLITE_OK {
        throw SQLiteError.Step(message: errorMessage)
      }
    }
  }
  
  static func update(with sql: String) throws {
    try serialQueue.sync {
      guard let updateStatement = try? store?.prepareStatement(sql: sql) else {
        throw SQLiteError.Prepare(message: Self.errorMessage)
      }
      defer {
        sqlite3_finalize(updateStatement)
      }
      if sqlite3_step(updateStatement) == SQLITE_DONE {
        throw SQLiteError.Step(message: Self.errorMessage)
      }
    }
  }
  
  static var errorMessage: String {
    return store?.errorMessage ?? "May something went wrong."
  }
}
