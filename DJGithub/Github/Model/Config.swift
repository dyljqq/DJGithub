//
//  Config.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/29.
//

import Foundation

struct Config: DJCodable {
  var authorization: String = ""
  let userName: String = "dyljqq"
  
  init() {
    
  }
  
  enum CodingKeys: String, CodingKey {
    case authorization
  }
}
