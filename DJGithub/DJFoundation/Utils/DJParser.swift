//
//  DJParser.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct DJParser: Parse {
  static let shared = DJParser()
}

struct DJDecoder<T:Decodable> {
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
  
  func decode() -> T? {
    guard let data = data else {
      return nil
    }
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      print("DJDecode Error: \(error)")
    }
    return nil
  }
}
