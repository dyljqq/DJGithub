//
//  Parse.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

protocol Parse {
  func parse(data: Data) async throws -> [String: Any]?
}

extension Parse {
  func parse(data: Data) async throws -> [String: Any]? {
    guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
      throw DJError.parseError("Invalid data.")
    }
    return dict
  }
}
