//
//  DJStucj.swift
//  DJMonitor
//
//  Created by jiqinqiang on 2022/10/20.
//

import Foundation

private let STUCK_MONITOR_THRESH_HOLD = 0.08

open class DJStuckMonitor {
  
  static let shared = DJStuckMonitor()
  
  var thread: thread_t?
  
  let dispatchSemaphore = DispatchSemaphore(value: 0)
  var runLoopActivity: CFRunLoopActivity = .entry
  var runloopObserver: CFRunLoopObserver?
  let queue = DispatchQueue(label: "stuck_monitor.dyljqq.com", attributes: .concurrent)
  
  var timer: Timer?
  var stackInfos: [[String]] = []
  var currentStackInfo: [String] = []
  
  fileprivate var monitorState = MonitorState()
  
  func config(with thread: thread_t) {
    self.thread = thread
  }
  
  func beginMonitor() {
    guard !monitorState.isMonitoring else { return }

    getStackInfos()
    
    let info = Unmanaged<DJStuckMonitor>.passUnretained(self).toOpaque()
    var context = CFRunLoopObserverContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
    runloopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0, runLoopObserverCallback(), &context)
    guard runloopObserver != nil else { return }
    
    monitorState.update(isMonitoting: true, timeoutCount: 0)
    CFRunLoopAddObserver(CFRunLoopGetMain(), runloopObserver, .commonModes)
    
    queue.async {
      while true {
        let wait = self.dispatchSemaphore.wait(timeout: DispatchTime.now() + STUCK_MONITOR_THRESH_HOLD)
        if DispatchTimeoutResult.timedOut == wait {
          if self.runloopObserver == nil {
            self.runLoopActivity = .entry
            return
          }
          
          if self.runLoopActivity == .beforeSources || self.runLoopActivity == .afterWaiting {
            if self.monitorState.timeoutCount < 3 {
              self.monitorState.update(isMonitoting: true, timeoutCount: self.monitorState.timeoutCount + 1)
              continue
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
              if let thread = self.thread {
                let infos = DJCallStack.fetchStackInfo(from: thread)
                self.currentStackInfo = infos
                self.outputInfos()
              }
            }
          }
        }
        self.monitorState.update(isMonitoting: true, timeoutCount: 0)
      }
    }
  }
  
  func endMonitor() {
    guard self.runloopObserver != nil else { return }
    self.monitorState.update(isMonitoting: false, timeoutCount: 0)
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.runloopObserver, .commonModes)
    self.runloopObserver = nil
  }
  
  private func getStackInfos() {
    queue.async {
      self.timer = Timer(timeInterval: 3, repeats: true, block: { [weak self] timer in
        guard let strongSelf = self, let thread = strongSelf.thread else { return }
        let infos = DJCallStack.fetchStackInfo(from: thread)
        if strongSelf.stackInfos.count > 20 {
          strongSelf.stackInfos.removeFirst()
        }
        strongSelf.stackInfos.append(infos)
      })
      let runloop = RunLoop.current
      runloop.add(self.timer!, forMode: .default)
      runloop.run()
    }
  }
  
  func cancelTimer() {
    if self.timer != nil {
      self.timer?.invalidate()
      self.timer = nil
    }
  }
  
  func runLoopObserverCallback() -> CFRunLoopObserverCallBack {
    return { observer, activity, info in
      guard let info = info else { return }
      let weakSelf = Unmanaged<DJStuckMonitor>.fromOpaque(info).takeUnretainedValue()
      weakSelf.runLoopActivity = activity
      weakSelf.dispatchSemaphore.signal()
    }
  }
  
  deinit {
    cancelTimer()
  }
  
}

extension DJStuckMonitor {
  fileprivate struct MonitorState {
    var isMonitoring: Bool
    var timeoutCount: Int
    
    init() {
      self.isMonitoring = false
      self.timeoutCount = 0
    }
    
    mutating func update(isMonitoting: Bool, timeoutCount: Int) {
      self.isMonitoring = isMonitoting
      self.timeoutCount = timeoutCount
    }
    
    mutating func reset() {
      self.isMonitoring = false
      self.timeoutCount = 0
    }
  }
}

/// output
extension DJStuckMonitor {
  private func outputInfos() {
    print("current info: \(self.currentStackInfo.joined(separator: "\n"))")
//    for info in self.stackInfos {
//      print("info: \(info.joined(separator: "\n"))")
//    }
  }
}
