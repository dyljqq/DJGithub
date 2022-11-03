//
//  DJMonitor.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/1.
//

import UIKit

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
  
  func addFPSMonitor(with window: UIWindow?) {
    if let window = window {
      let label = DJFPSLabel(
        frame: CGRect(x: FrameGuide.screenWidth - 71, y: FrameGuide.screenHeight - FrameGuide.tabbarHeight - 44, width: 55, height: 20))
      window.addSubview(label)
    }
  }
}
