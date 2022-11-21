//
//  DJObserverable.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/22.
//

import Foundation

class DJObserverable<T> {
  var value: T? {
    didSet {
      listener?(value)
    }
  }

  private var listener: ((T?) -> Void)?

  init(value: T? = nil) {
    self.value = value
  }

  func bind(_ listener: @escaping (T?) -> Void) {
    self.listener = listener
  }
}
