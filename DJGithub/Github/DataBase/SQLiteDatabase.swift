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
  
  let dbPath = "github.sqlite"
  
  let serialQueue = DispatchQueue(label: "com.dyljqq.dbmanager")
  
  fileprivate var errorMessage: String {
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
  
  @discardableResult
  func execute<T: SQLTable>(_ operation: SqlOperation, sql: String, model: T? = nil, type: T.Type? = nil) -> Any? {
    self.serialQueue.sync {
      switch operation {
      case .insert:
        if let model = model {
          self.insert(sql, model)
        }
      case .select:
        if let type = type {
          return self.select(sql, type)
        }
      case .delete:
        self.delete(sql: sql)
      case .update:
        self.update(sql)
      case .createTable:
        self.createTable(sql)
      }
      return nil
    }
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
  
  func createTable(_ sql: String) {
    print("table sql: ```\(sql)```")
    var createTableStatement: OpaquePointer?
    if sqlite3_prepare_v2(db, sql, -1, &createTableStatement, nil) == SQLITE_OK {
      if sqlite3_step(createTableStatement) == SQLITE_DONE {
        print("table created.")
      } else {
        print("table could not be created.")
      }
    } else {
      print("CREATE TABLE statement could not be prepared.")
    }
    sqlite3_finalize(createTableStatement)
  }
  
  func insert<T: SQLTable>(_ sql: String, _ model: T) {
    guard !sql.isEmpty else {
      print("sql cannot be empty....")
      return
    }
    
    var insertStatement: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &insertStatement, nil) == SQLITE_OK else {
      return
    }
    
    for (index, field) in T.fields.enumerated() {
      if let fieldType = T.fieldsTypeMapping[field] {
        let offset = Int32(index) + 1
        
        switch fieldType {
        case .int:
          if let value = model.fieldsValueMapping[field] as? Int {
            sqlite3_bind_int(insertStatement, offset, Int32(value))
          }
        case .text:
          let text: String = model.fieldsValueMapping[field] as? String ?? ""
          sqlite3_bind_text(insertStatement, offset, (text as NSString).utf8String, -1, nil)
        case .bigint:
          if let value = model.fieldsValueMapping[field] as? Int {
            sqlite3_bind_int64(insertStatement, offset, Int64(value))
          }
        default:
          break
        }
      }
      sqlite3_reset(insertStatement)
    }
    
    let code = sqlite3_step(insertStatement)
    if code != SQLITE_DONE {
      print("Could not insert row: \(code)")
      print("sql: \(sql)")
    }
    
    sqlite3_finalize(insertStatement)
  }
  
  @discardableResult
  func select<T: SQLTable>(_ sql: String, _ model: T.Type) -> [[String: Any]] {
    var selectStatement: OpaquePointer?
    let status = sqlite3_prepare_v2(db, sql, -1, &selectStatement, nil)
    guard status == SQLITE_OK else {
      print("select error: status: \(status)")
      return []
    }
    
    var rs: [[String: Any]] = []
    while sqlite3_step(selectStatement) == SQLITE_ROW {
      var hash: [String: Any] = [:]
      for (index, field) in T.selectedFields.enumerated() {
        let offset = Int32(index)
        if let typ = T.fieldsTypeMapping[field] {
          switch typ {
          case .int:
            hash[field] = sqlite3_column_int(selectStatement, offset)
          case .text:
            if let v = sqlite3_column_text(selectStatement, offset) {
              hash[field] = String(cString: v)
            }
          case .bigint:
            hash[field] = sqlite3_column_int64(selectStatement, offset)
          default: break
          }
        }
      }
      rs.append(hash)
    }
    
    sqlite3_finalize(selectStatement)
    
    return rs
  }
  
  func update(_ sql: String) {
    var updateStatement: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &updateStatement, nil) == SQLITE_OK else {
      return
    }
    
    let status = sqlite3_step(updateStatement)
    guard status == SQLITE_DONE else {
      print("update error...")
      return
    }
    sqlite3_finalize(updateStatement)
  }
  
  func delete(sql: String) {
    var deleteStatement: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &deleteStatement, nil) == SQLITE_OK else {
      return
    }
    
    let status = sqlite3_step(deleteStatement)
    if status != SQLITE_DONE {
      print("delete error: \(status)")
    }
    
    sqlite3_finalize(deleteStatement)
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
  
  func createTable(table: SQLTable.Type) throws {
    try serialQueue.sync {
      let createTableStatement = try prepareStatement(sql: table.tableSql)
      defer {
        sqlite3_finalize(createTableStatement)
      }
      
      guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
        throw SQLiteError.Step(message: errorMessage)
      }
      print("\(table) table created.")
    }
  }
}
