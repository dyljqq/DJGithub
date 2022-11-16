//
//  SqlCountModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/4.
//

import Foundation

struct SqlCountModel: DJCodable {
  var count: Int

  static func query(with tableName: String, condition: String = "") -> Self? {
    serialQueue.sync {
      let sql = "select count(1) from \(tableName) \(condition);"
      if let rs = try? SQLiteDatabase.queryCount(with: sql) {
        return try? DJDecoder(dict: rs).decode()
      }
      return nil
    }
  }
}

struct SqlMaxModel: DJCodable {
  var maxValue: String

  static func query(with tableName: String, fieldName: String, condition: String = "") -> Self? {
    let sql = "select max(\(fieldName)) from \(tableName) \(condition)"
    if let rs = try? SQLiteDatabase.queryCount(with: sql) {
      if let count = rs["count"] as? String {
        return SqlMaxModel(maxValue: count)
      }
    }
    return nil
  }
}
