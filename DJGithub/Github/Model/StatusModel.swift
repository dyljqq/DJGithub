//
//  StatusModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/28.
//

import Foundation

struct StatusModel: Decodable {
  var statusCode: Int
  
  var isStatus204: Bool {
    return statusCode == 204
  }
}
