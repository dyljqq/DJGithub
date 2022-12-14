//
//  DJCallStack.swift
//  DJMonitor
//
//  Created by jiqinqiang on 2022/10/20.
//

import Foundation
import Darwin.machine

@_silgen_name("mach_frame_count")
public func getMachFrameCount(
    from thread: thread_t,
    stack: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
    maxSymbolCount: Int32
) -> Int

private let taskBasicInfoCount = mach_msg_type_number_t(MemoryLayout<task_basic_info_data_t>.size /  MemoryLayout<UInt32>.size)
public typealias Mcontext = UnsafeMutablePointer<__darwin_mcontext64>

struct DJCallStack {
  static func fetchStackInfo(_ completionHandler: @escaping ([String]) -> Void) {
    DispatchQueue.main.async {
      let infos = getStackInfo(by: mach_thread_self())
      completionHandler(infos)
    }
  }

  static func fetchStackInfo(from thread: thread_t) -> [String] {
    return getStackInfo(by: thread)
  }
}

extension DJCallStack {
  fileprivate static func getStackInfo(by thread: thread_t) -> [String] {
    var info = thread_basic_info()
    var infoCount = taskBasicInfoCount
    let kerr = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        thread_info(thread, thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
      }
    }
    guard kerr == KERN_SUCCESS else { return [] }

    var rs = [String]()
    if (info.flags & TH_FLAGS_IDLE) == 0 {
      let cpuUsage = Double(info.cpu_usage) / 10
      let userTime = Double(info.system_time.seconds) + Double(info.system_time.microseconds / 1000000)
      let threadInfoModel = DJThreadInfoModel(thread: thread, cpuUsage: cpuUsage, userTime: userTime)
      rs.append(threadInfoModel.description)
    }

    let maxSize: Int32 = 100
    let address = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: Int(maxSize))
    defer {
      address.deallocate()
    }

    let frameCount = getMachFrameCount(from: thread, stack: address, maxSymbolCount: maxSize)
    let frames = UnsafeBufferPointer(start: address, count: frameCount)
    for (idx, frame) in frames.enumerated() {
      guard let frame = frame else { break }
      let address = UInt(bitPattern: frame)
      let addressInfo = StackAddressInfo(address: address)
      rs.append(addressInfo.formattedDescription(index: idx))
    }
    return rs
  }
}
