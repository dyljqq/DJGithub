//
//  DJFileManager.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

struct DJFileManager {

  static let shared = DJFileManager()

  func getFile(with fileName: String) -> [String: Any] {
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist") else {
      return [:]
    }
    guard let dict = NSDictionary(contentsOfFile: filePath) as? [String: Any] else {
      return [:]
    }
    return dict
  }

}
