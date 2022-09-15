//
//  Result.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

extension Result {
  
  func parse<T: Decodable>() -> T? {
    switch self {
    case .success(let d):
      if let d = d as? [String: Any] {
        return DJDecoder(dict: d).decode()
      }
    case .failure:
      break
    }
    return nil
  }
  
}
