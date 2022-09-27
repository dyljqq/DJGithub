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
  case statusCode(Int)
  case dataError
  case other(Error)
  case unknown
  
  static func map(_ error: Error) -> DJError {
    return (error as? DJError) ?? .other(error)
  }
}
