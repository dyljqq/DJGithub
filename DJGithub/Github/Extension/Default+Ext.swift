//
//  Default+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/2.
//

import Foundation

extension Bool {
  enum False: DefaultValue {
    static let defaultValue = false
  }
  enum True: DefaultValue {
    static let defaultValue = true
  }
}

extension Default {
  typealias True = Default<Bool.True>
  typealias False = Default<Bool.False>
}

extension String: DefaultValue {
  static let defaultValue = ""
  
  enum UnProvidedDesc: DefaultValue {
    static let defaultValue = "No description provided."
  }
  enum Company: DefaultValue {
    static let defaultValue = "团队"
  }
  enum Email: DefaultValue {
    static let defaultValue = "邮箱"
  }
  enum Location: DefaultValue {
    static let defaultValue = "地点"
  }
  enum Blog: DefaultValue {
    static let defaultValue = "个人主页"
  }
}
