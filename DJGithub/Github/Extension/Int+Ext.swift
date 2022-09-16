//
//  Int+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/17.
//

import Foundation

extension Int {
  var toGitNum: String {
    if self > 1000 {
      return "\(String(format: "%.1f", Double(self) / 1000))k"
    }
    return "\(self)"
  }
}
