//
//  DJObjectProxy.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/3.
//

import UIKit

class DJObjectProxy: NSObject {

  weak var weakTarget: NSObject?
  weak var weakHost: NSObject?
  weak var responder: NSObject?

  var checkFailCount = 0
  var hasNotified = false

  func prepareProxy(with target: NSObject?) {
    weakTarget = target

    NotificationCenter.default.addObserver(forName: .snifferPing, object: nil, queue: .main, using: { [weak self] _ in
      self?.detect()
    })
  }

  private func detect() {
    guard !hasNotified, let target = weakTarget else { return }
    let alive = target.isAlive()
    if !alive {
      checkFailCount = checkFailCount + 1
    }

    if checkFailCount > 5 {
      self.notifyPossibleMemoryLeak()
    }
  }

  private func notifyPossibleMemoryLeak() {
    guard !hasNotified else { return }
    hasNotified = true
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: .snifferPong, object: self.weakTarget)
    }
  }

}
