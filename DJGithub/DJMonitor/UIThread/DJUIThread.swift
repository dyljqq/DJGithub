//
//  DJUIThread.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/8.
//

import UIKit

class DJUIThreadMonitor {
  static func start() {
    UIView.swizzleInstanceMethod(
      origSelector: #selector(UIView.setNeedsLayout),
      toAlterSelector: #selector(UIView.swizzled_setNeedsLayout)
    )
    UIView.swizzleInstanceMethod(
      origSelector: #selector(UIView.setNeedsDisplay(_:)),
      toAlterSelector: #selector(UIView.swizzled_setNeedsDisplay(_:))
    )
  }
}

extension UIView {
  
  @objc func swizzled_setNeedsLayout() {
    self.checkThread()
    self.swizzled_setNeedsLayout()
  }
  
  @objc func swizzled_setNeedsDisplay(_ rect: CGRect) {
    self.checkThread()
    self.swizzled_setNeedsDisplay(rect)
  }
  
  private func checkThread() {
    if !Thread.isMainThread {
      print("-------------")
      print("Warning!!!!!!!!!!!!")
      print("thread: \(Thread.current), is on main thread: \(Thread.isMainThread)...")
      print("-------------")
    }
  }
  
}
