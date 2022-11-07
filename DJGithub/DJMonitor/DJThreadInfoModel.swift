//
//  DJThreadInfoModel.swift
//  DJMonitor
//
//  Created by jiqinqiang on 2022/10/20.
//

import Foundation

struct DJThreadInfoModel {
  let thread: thread_t
  let cpuUsage: Double
  let userTime: Double
  
  var description: String {
    return "Thread: \(thread), CPU usage: \(self.cpuUsage), use \(self.userTime) seconds."
  }
}
