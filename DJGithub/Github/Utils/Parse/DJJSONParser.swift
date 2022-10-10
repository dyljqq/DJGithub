//
//  DJJSONParser.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/10.
//

import Foundation

class DJJSONParser<T: DJCodable>: JSONDecoder, Parsable {
  
  typealias DataType = T
  
  override init() {
    super.init()
    self.keyDecodingStrategy = .convertFromSnakeCase
  }
  
  func parse(with data: Data?) async throws -> T? {
    guard let data = data else { return nil }
    do {
      return try self.decode(T.self, from: data)
    } catch {
      throw DJError.parseError("\(error)")
    }
  }
}
