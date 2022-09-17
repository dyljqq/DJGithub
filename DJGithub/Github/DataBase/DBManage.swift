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
}

let store = DBManager()

class DBManager {
    
    let dbPath = "github.sqlite"
    
    let serialQueue = DispatchQueue(label: "com.dyljqq.dbmanager")
    
    var db: OpaquePointer?
    
    init() {
        
    }
    
    @discardableResult
    func execute<T: SQLTable>(_ operation: SqlOperation, sql: String, model: T? = nil, type: T.Type? = nil) -> Any? {
        self.serialQueue.sync {
            self.db = openDatabase()
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
            }
            
            self.closeDatabase(db)
            
            return nil
        }
    }
    
    func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)

        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            sqlite3_close(db)
            print("error open database~")
            return nil
        }
        return db
    }
    
    func closeDatabase(_ db: OpaquePointer?) {
        sqlite3_close(db)
    }
    
    func createTable(_ sql: String) {
        print("table sql: ```\(sql)```")
        
        self.db = openDatabase()
        
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
        
        self.closeDatabase(db)
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
                default:
                    break
                }
            }
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
            let id = sqlite3_column_int(selectStatement, 0)
            
            hash["id"] = id
            for (index, field) in T.fields.enumerated() {
                let offset = Int32(index) + 1
                if let typ = T.fieldsTypeMapping[field] {
                    switch typ {
                    case .int:
                        hash[field] = sqlite3_column_int(selectStatement, offset)
                    case .text:
                        if let v = sqlite3_column_text(selectStatement, offset) {
                            hash[field] = String(cString: v)
                        }
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
}
