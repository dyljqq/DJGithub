//
//  DJThreadInfoModel.swift
//  DJMonitor
//
//  Created by jiqinqiang on 2022/10/20.
//

import Foundation

struct DJThreadInfoModel {
  var cpuUsage: Double
  var userTime: Int
  
  init() {
    self.cpuUsage = 0
    self.userTime = 0
  }
  
  init(cpuUsage: Double, userTime: Int) {
    self.cpuUsage = cpuUsage
    self.userTime = userTime
  }
  
  var description: String {
    return "Thread CPU usage: \(self.cpuUsage), use \(self.userTime) microseconds."
  }
}
