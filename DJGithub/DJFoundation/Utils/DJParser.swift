//
//  DJParser.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct DJDecoder<T:DJCodable> {
  let decoder = JSONDecoder()
  
  private var data: Data?
  
  init(dict: [String: Any]) {
    let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    self.init(data: data)
  }
  
  init(data: Data?) {
    self.data = data
    decoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  init(value: Any) {
    let data = try? JSONSerialization.data(withJSONObject: value)
    self.init(data: data)
  }
  
  func decode() throws -> T? {
    guard let data = data else { return nil }
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw DJError.parseError("\(error)")
    }
  }
}

struct DJEncoder<T: Encodable> {
  let encoder = JSONEncoder()
  
  let model: T?
  
  init(model: T?) {
    self.model = model
    encoder.keyEncodingStrategy = .convertToSnakeCase
  }
  
  func encode() -> Any? {
    guard let model = model else { return nil }
    do {
      let data = try encoder.encode(model)
      return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    } catch {
      print("JDEncode Error: \(error)")
    }
    return nil
  }
}
