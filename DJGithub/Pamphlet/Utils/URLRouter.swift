//
//  URLRouter.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import Foundation

private let baseScheme = "djgithub"
private let urlMapping = [
  "pamaphletMain": PamphletViewController.classForCoder()
]

struct URLRouterModel {
  let scheme: String
  let host: String
  let path: String
  let queryItems: [URLQueryItem]?
}

struct URLRouter {
  static func open(with urlString: String?) {
    print(urlString?.urlRouterModel)
  }
}

extension String {
  var urlRouterModel: URLRouterModel? {
    guard let url = URL(string: self) else { return nil }
    guard let scheme = url.scheme, scheme == baseScheme else { return nil }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    return URLRouterModel(scheme: scheme, host: url.host ?? "", path: url.path, queryItems: components.queryItems)
  }
}
