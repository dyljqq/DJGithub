//
//  StatusModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import Foundation

struct StatusModel: DJCodable {
  var statusCode: Int
  
  var isStatus204: Bool {
    return statusCode == 204
  }
}
