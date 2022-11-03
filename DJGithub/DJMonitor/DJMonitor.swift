//
//  DJMonitor.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/1.
//

import Foundation

struct DJMonitor {
  static let shared = DJMonitor()
  
  init(){
    
  }
  
  func monitor() {
    // 获取APP启动时间
    AppStartTimeMonitor.shared.measure()
    
    // 开启卡顿检测
    DJStuckMonitor.shared.config(with: mach_thread_self())
    DJStuckMonitor.shared.beginMonitor()
    
    // 开启crash监控
    DJCrashManager.shared.registerHandler()
    
    // 开启内存泄漏检测
    DJLeakSniffer.shared.install()
  }
}
