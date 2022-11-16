//
//  DispatchQueue+Leak.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/3.
//

import Foundation

public extension DispatchQueue {
  fileprivate static var tokens: [String] = []

  class func once(_ file: String = #file, function: String = #function, line: Int = #line, block: () -> Void) {
    let token = file + ":" + function + ":" + String(line)
    once(token: token, block: block)
  }

  class func once(token: String, block:() -> Void) {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }
    guard !tokens.contains(token) else { return }
    tokens.append(token)
    block()
  }
}
