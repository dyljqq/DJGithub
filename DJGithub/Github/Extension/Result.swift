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
        if let statusCode = d["statusCode"] as? Int,
           ![204, 404].contains(statusCode) {
          print("result parse error, status code:\(statusCode)")
          return nil
        }
        return DJDecoder(dict: d).decode()
      }
    case .failure(let error):
      print("result parse error: \(error)")
      break
    }
    return nil
  }
  
}
