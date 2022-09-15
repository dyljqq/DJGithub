//
//  Error.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

enum DJError: Error {
  case invalidURL(String)
  case parseError(String)
  case requestError
  case unknown
}
