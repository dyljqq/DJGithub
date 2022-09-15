//
//  Router.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/9/15.
//

import Foundation

enum HTTPMethod: String {
  case GET
  case POST
}

protocol Router: URLRequestConvertible {
  var baseURLString: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String] { get }
  var parameters: [String: Any] { get }
  var path: String { get }
}

extension Router {
  var method: HTTPMethod {
    return .GET
  }
  
  var headers: [String: String] {
    return [:]
  }
  
  var parameters: [String: Any] {
    return [:]
  }
  
  var path: String {
    return ""
  }
  
  var urlString: String {
    guard let request = self.asURLRequest(), var str = request.url?.absoluteString else {
        return ""
    }
    if str.last == "/" {
        str.removeLast()
    }
    return str
  }
  
  func configURLRequest() -> URLRequest? {
    guard let url = try? baseURLString.asURL() else {
        return nil
    }
    var request = URLRequest(url: url.appendingPathComponent(path))
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    request.timeoutInterval = TimeInterval(10 * 1000)
    return request
  }
  
  func asURLRequest() -> URLRequest? {
    return configURLRequest()
  }
}
