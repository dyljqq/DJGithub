//
//  AppStartTimeMonitor.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/31.
//

import Foundation

class AppStartTimeMonitor {

  static let shared = AppStartTimeMonitor()

  private var runloopObserver: CFRunLoopObserver?

  private let pid = ProcessInfo().processIdentifier
  private var currentTime = timeval(tv_sec: 0, tv_usec: 0)
  private var size = MemoryLayout<kinfo_proc>.stride
  private var kp = kinfo_proc()  // kp instead of bootTime
  private var mib: [Int32]

  init() {
    mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
  }

  func processLaunchTime() -> Double {
    sysctl(&mib, u_int(mib.count), &kp, &size, nil, 0)
    gettimeofday(&currentTime, nil)
    let bootTime = kp.kp_proc.p_un.__p_starttime  // this is a timeval struct
    return toSeconds(time: currentTime) - toSeconds(time: bootTime)
  }

  private func toSeconds(time: timeval) -> Double {
    let microsecondsInSecond = 1000000.0
    return Double(time.tv_sec) + Double(time.tv_usec) / microsecondsInSecond
  }

  func measure() {
    let info = Unmanaged<AppStartTimeMonitor>.passUnretained(self).toOpaque()
    var context = CFRunLoopObserverContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
    runloopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0, runLoopObserverCallback(), &context)
    guard runloopObserver != nil else { return }
    CFRunLoopAddObserver(CFRunLoopGetMain(), runloopObserver, .commonModes)
  }

  func runLoopObserverCallback() -> CFRunLoopObserverCallBack {
    return { observer, activity, info in
      guard let info = info else { return }
      let weakSelf = Unmanaged<AppStartTimeMonitor>.fromOpaque(info).takeUnretainedValue()
      if activity == .beforeTimers {
        // use before timers to cal app launch time.
        print("runloop beforetimers launch: \(weakSelf.processLaunchTime())")
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, .commonModes)
      }
    }
  }
}
