//
//  URLRouterModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/20.
//

import UIKit

struct URLRouterModel {
  let scheme: String
  let host: String
  let path: String
  let queryItems: [URLQueryItem]?

  var transition: VCTransition = .push

  var mapping: [String: String] {
    guard let queryItems = queryItems else { return [:] }
    var hash: [String: String] = [:]
    queryItems.forEach { hash[$0.name] = $0.value }
    return hash
  }

  var hostVCType: HostVCType? {
    return HostVCType(rawValue: host)
  }

  var vc: UIViewController? {
    return hostVCType?.getVC(with: mapping)
  }
}
