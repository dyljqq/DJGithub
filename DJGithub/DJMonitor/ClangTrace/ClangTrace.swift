//
//  DJClangTrace.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/14.
//

import Foundation

struct ClangTrace {
  static let shared = ClangTrace()
  
  func outputOrderFile() {
    DispatchQueue.global(qos: .utility).async {
      DJClangTrace.generateOrderFile()
    }
  }
}
