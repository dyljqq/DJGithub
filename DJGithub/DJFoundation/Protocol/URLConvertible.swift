//
//  URLConvertible.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

public protocol URLRequestConvertible {
  func asURLRequest() -> URLRequest?
}

extension URLRequestConvertible {
  public var urlRequest: URLRequest? { return asURLRequest() }
}

public protocol URLConvertible {
  func asURL() throws -> URL
}

extension String: URLConvertible {
  public func asURL() throws -> URL {
    guard let url = URL(string: self) else {
      throw DJError.invalidURL("Error: Invalid URLString: " + self)
    }
    return url
  }
}
