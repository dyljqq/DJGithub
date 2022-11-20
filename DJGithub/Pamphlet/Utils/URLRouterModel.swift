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
  let type: HostVCType?
  let queryItems: [String: String]

  var transition: VCTransition = .push

  var vc: UIViewController? {
    return type?.getVC(with: queryItems)
  }
}
