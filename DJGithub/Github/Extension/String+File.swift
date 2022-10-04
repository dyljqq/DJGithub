//
//  String+File.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/4.
//

import Foundation

extension String {
  var fileSuffix: String? {
    let arr = self.components(separatedBy: ".")
    guard arr.count > 1 else {
      return nil
    }
    return arr.last
  }
}
