//
//  URL+Ext.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/20.
//

import Foundation

extension URL {
  func appending(by queryItems: [String: String]) -> URL {
    guard !queryItems.isEmpty, var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
      return self
    }
    urlComponents.queryItems = urlComponents.queryItems ?? [] + queryItems.map { URLQueryItem(name: $0, value: $1) }
    return urlComponents.url != nil ? urlComponents.url! : self
  }
}
