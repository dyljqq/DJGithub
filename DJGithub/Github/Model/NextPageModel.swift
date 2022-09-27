//
//  NextPageModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/27.
//

import Foundation

struct NextPageModel {
  
  var nextIndex: Int = 0
  var dataSource: [Any] = []
  var isEnding: Bool = false
  
  init() {
    self.nextIndex = 0
    self.dataSource = []
    self.isEnding = false
  }
  
  init(nextIndex: Int, dataSource: [Any], isEnding: Bool) {
    self.nextIndex = nextIndex
    self.dataSource = dataSource
    self.isEnding = isEnding
  }
  
  mutating func update(nextIndex: Int, dataSource: [Any], isEnding: Bool) {
    self.nextIndex = nextIndex
    self.dataSource = dataSource
    self.isEnding = isEnding
  }
  
}
