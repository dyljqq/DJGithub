//
//  Bool+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import Foundation

extension Bool {

  var followText: String {
    return self ? "UnFollow" : "Follow"
  }

  var starText: String {
    return self ? "UnStar" : "Star"
  }

}
